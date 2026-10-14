"""
load_content_documents.py

Loads the extracted Salesforce Files from local disk into the TARGET (Rhombus) org,
driven by the manifests the extraction already produced:

    content_documents.csv        one row per file   (TargetContentVersionId / TargetContentDocumentId / TargetLoadStatus)
    content_document_links.csv   one row per link   (TargetLinkedEntityId / TargetLinkStatus / ...)

Three steps, each safe to re-run (state lives in the two CSVs, so it resumes where it stopped):

    Step 0  map_target_entities()  fill TargetLinkedEntityId from sfrhd.<Object>.Metazoa_External_ID__c
    Step 1  upload_versions()      insert one ContentVersion per file, then resolve its ContentDocumentId
    Step 2  create_links()         insert ContentDocumentLink rows (file -> target parent record)

Typical use from your notebook (re-using the connections you already have):

    import load_content_documents as lcd
    lcd.map_target_entities(engine)                     # Step 0
    lcd.upload_versions(dst_sf_instance, engine, limit=25)   # Step 1 - TEST with a small limit first
    lcd.create_links(dst_sf_instance)                   # Step 2
    lcd.summary()

Requirements:  pip install pandas simple_salesforce sqlalchemy pyodbc requests_toolbelt
"""

import os
import io
import json
import time
import base64
import hashlib
import logging
from concurrent.futures import ThreadPoolExecutor, as_completed

import pandas as pd
from sqlalchemy import text

# ------------------------------- CONFIG -------------------------------------
BASE_DIR = r"E:\Files_Extract\Salesforce_ContentDocuments"   # folder holding the CSVs and the "Files" folder
DOCS_FILE = "content_documents.csv"
LINKS_FILE = "content_document_links.csv"

SMALL_FILE_LIMIT = 30 * 1024 * 1024   # <= this goes as base64 JSON; larger files go as streamed multipart
WORKERS = 6                           # parallel uploads (Salesforce allows ~25 concurrent long-running requests)
CHECKPOINT_EVERY = 1000               # save the CSVs after this many processed files
VERIFY_SHA256 = True                  # compare local file hash with the SHA256 captured at extraction
ONLY_IF_LINKABLE = True               # don't upload a file unless at least one of its parents exists in target

# Stamp the source ContentVersion Id on the target record so a crash between "uploaded" and "saved to CSV"
# can be reconciled instead of creating duplicates. REQUIRES a custom text field (External ID) on
# ContentVersion in the target. Set to None to disable.
SRC_ID_FIELD = "Metazoa_External_ID__c"

# Preserve original created date / creator. REQUIRES the "Set Audit Fields upon Record Creation" permission
# on the integration user in the target org. If that permission is missing every insert will fail - switch off.
PRESERVE_AUDIT_FIELDS = True

# How to carry over the original creator (needs PRESERVE_AUDIT_FIELDS):
#   "with_owner" : CreatedById AND OwnerId are both set to the mapped target user. Both are needed - setting only
#                  CreatedById puts the file in that user's private library and Salesforce rejects it unless that
#                  user also owns it ("Documents in a user's private library must always be owned by that user").
#   "off"        : creator/owner are not set (files belong to the integration user); CreatedDate is still preserved.
CREATED_BY_MODE = "with_owner"

# Safety guard against writing to the wrong org (e.g. sandbox manifests against production). Set this to the host
# you intend to load, exactly as `print(sf.sf_instance)` shows it. Every function that WRITES to Salesforce then
# refuses to run if the connection points anywhere else. None = no guard.
TARGET_HOST = None
# -----------------------------------------------------------------------------

log = logging.getLogger("load_content_documents")
if not log.handlers:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")


# ------------------------------ helpers ---------------------------------------
def _docs_path():
    return os.path.join(BASE_DIR, DOCS_FILE)


def _links_path():
    return os.path.join(BASE_DIR, LINKS_FILE)


def _read(path):
    return pd.read_csv(path, dtype=str, keep_default_na=False, encoding="utf-8-sig")


def _save(df, path):
    """Atomic save so a crash mid-write can never corrupt the manifest."""
    tmp = path + ".tmp"
    df.to_csv(tmp, index=False, encoding="utf-8-sig", lineterminator="\r\n")
    os.replace(tmp, path)


def local_path(relative_path):
    """Manifest path -> real path. Uses the \\\\?\\ prefix so very long paths still open on Windows."""
    p = os.path.normpath(os.path.join(BASE_DIR, relative_path.replace("/", os.sep)))
    if os.name == "nt" and not p.startswith("\\\\?\\"):
        p = "\\\\?\\" + p
    return p


def sha256_file(path, chunk=8 * 1024 * 1024):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while True:
            b = f.read(chunk)
            if not b:
                break
            h.update(b)
    return h.hexdigest()


RETRY_MARKERS = ("REQUEST_LIMIT_EXCEEDED", "UNABLE_TO_LOCK_ROW", "503", "502", "429",
                 "ConnectionError", "Read timed out", "Connection aborted", "ServerUnavailable")


def with_retry(fn, attempts=5, base_delay=2):
    """Retry transient Salesforce / network errors with exponential backoff; anything else is raised straight away."""
    for i in range(1, attempts + 1):
        try:
            return fn()
        except Exception as e:  # noqa
            msg = f"{type(e).__name__}: {e}"
            if i == attempts or not any(m in msg for m in RETRY_MARKERS):
                raise
            delay = base_delay * (2 ** (i - 1))
            log.warning(f"Transient error ({msg[:120]}) - retry {i}/{attempts - 1} in {delay}s")
            time.sleep(delay)


def _check_target(sf):
    if TARGET_HOST and sf.sf_instance.lower() != TARGET_HOST.lower():
        raise RuntimeError(f"Connected to '{sf.sf_instance}' but TARGET_HOST is '{TARGET_HOST}' - refusing to write.")


def _chunks(seq, n):
    seq = list(seq)
    for i in range(0, len(seq), n):
        yield seq[i:i + n]


# ----------------------- Step 0: map parents to target ------------------------
def map_target_entities(engine):
    """
    Fill TargetLinkedEntityId by joining SourceLinkedEntityId to sfrhd.<LinkedEntityType>.Metazoa_External_ID__c
    (same convention your upsert views use). Re-run after more parent objects are loaded and the sfrhd
    staging tables are refreshed - rows that had no parent yesterday get picked up today.
    """
    links = _read(_links_path())
    done = links["TargetLinkStatus"].isin(["Linked"])

    for etype, grp in links[~done & (links["TargetLinkedEntityId"] == "")].groupby("LinkedEntityType"):
        try:
            m = pd.read_sql(
                text(f"SELECT [Id], [Metazoa_External_ID__c] FROM [sfrhd].[{etype}] "
                     f"WHERE [Metazoa_External_ID__c] IS NOT NULL"), engine)
        except Exception as e:  # table missing in the staging schema, etc.
            log.warning(f"{etype:40s} cannot read sfrhd.[{etype}] -> {str(e)[:100]}")
            continue

        dups = m["Metazoa_External_ID__c"].duplicated().sum()
        if dups:
            log.warning(f"{etype:40s} {dups} duplicate Metazoa_External_ID__c values in target - last one wins")
        lookup = dict(zip(m["Metazoa_External_ID__c"], m["Id"]))

        mask = (links["LinkedEntityType"] == etype) & ~done & (links["TargetLinkedEntityId"] == "")
        links.loc[mask, "TargetLinkedEntityId"] = links.loc[mask, "SourceLinkedEntityId"].map(lookup).fillna("")
        mapped = (links.loc[mask, "TargetLinkedEntityId"] != "").sum()
        log.info(f"{etype:40s} {mapped:>6} / {mask.sum():>6} links mapped")

    has_parent = links["TargetLinkedEntityId"] != ""
    pending = links["TargetLinkStatus"].isin(["PendingTargetMapping", "NoTargetParent"])
    links.loc[pending & has_parent, "TargetLinkStatus"] = "ReadyToLink"
    links.loc[pending & ~has_parent, "TargetLinkStatus"] = "NoTargetParent"
    _save(links, _links_path())

    log.info("Link status now:\n" + links["TargetLinkStatus"].value_counts().to_string())
    return links


# ----------------------------- Step 1: upload ---------------------------------
def _load_user_map(engine):
    """Source user Id -> target user Id (for CreatedById), via sfrhd.User.Metazoa_External_ID__c."""
    m = pd.read_sql(text("SELECT [Id], [Metazoa_External_ID__c] FROM [sfrhd].[User] "
                         "WHERE [Metazoa_External_ID__c] IS NOT NULL"), engine)
    return dict(zip(m["Metazoa_External_ID__c"], m["Id"]))


def _upload_one(sf, row, user_map):
    """Upload a single file. Returns a result dict; never raises."""
    res = {"idx": row["_idx"], "version_id": "", "status": "", "error": ""}
    try:
        path = local_path(row["CanonicalRelativePath"])
        if not os.path.exists(path):
            res.update(status="MissingFile", error=path)
            return res

        size = os.path.getsize(path)
        if row["ContentSize"] and size != int(row["ContentSize"]):
            res.update(status="SizeMismatch", error=f"local {size} vs source {row['ContentSize']}")
            return res

        if VERIFY_SHA256 and row["SHA256"] and sha256_file(path) != row["SHA256"].lower():
            res.update(status="HashMismatch", error="SHA256 differs from extraction")
            return res

        meta = {"Title": row["Title"] or row["OriginalFileName"],
                "PathOnClient": row["OriginalFileName"]}
        if SRC_ID_FIELD:
            meta[SRC_ID_FIELD] = row["SourceContentVersionId"]
        if PRESERVE_AUDIT_FIELDS:
            if row["SourceCreatedDate"]:
                meta["CreatedDate"] = row["SourceCreatedDate"]
            uid = user_map.get(row["SourceCreatedById"])
            if uid and CREATED_BY_MODE == "with_owner":
                meta["CreatedById"] = uid
                meta["OwnerId"] = uid          # must match CreatedById or Salesforce rejects the insert

        if size <= SMALL_FILE_LIMIT:
            with open(path, "rb") as f:
                meta["VersionData"] = base64.b64encode(f.read()).decode("ascii")
            out = with_retry(lambda: sf.ContentVersion.create(meta))
            res.update(version_id=out["id"], status="Uploaded")
        else:
            from requests_toolbelt.multipart.encoder import MultipartEncoder  # streams - no full-file RAM copy

            def _post_big():
                with open(path, "rb") as f:
                    enc = MultipartEncoder(fields={
                        "entity_content": (None, json.dumps(meta), "application/json"),
                        "VersionData": (row["OriginalFileName"], f, "application/octet-stream"),
                    })
                    headers = dict(sf.headers)
                    headers["Content-Type"] = enc.content_type
                    r = sf.session.post(f"{sf.base_url}sobjects/ContentVersion", data=enc,
                                        headers=headers, timeout=(30, 3600))
                    if r.status_code not in (200, 201):
                        raise RuntimeError(f"HTTP {r.status_code}: {r.text[:500]}")
                    return r.json()

            out = with_retry(_post_big)
            res.update(version_id=out["id"], status="Uploaded")
    except Exception as e:  # noqa
        content = getattr(e, "content", None)          # simple_salesforce keeps Salesforce's JSON error here
        detail = json.dumps(content) if content else str(e)
        res.update(status="Failed", error=f"{type(e).__name__}: {detail[:600]}")
    return res


def reconcile_from_target(sf, docs, candidates):
    """
    Crash recovery: any candidate file already in the target (stamped with SRC_ID_FIELD) but not recorded
    in the CSV gets its Target ids written back instead of being uploaded a second time.
    Only the files about to be uploaded are checked (so limit=25 means 25, not all 85k).
    """
    if not SRC_ID_FIELD or len(candidates) == 0:
        return docs
    pos = {docs.at[i, "SourceContentVersionId"]: i for i in candidates}
    src_ids = list(pos)
    log.info(f"Checking target for {len(src_ids)} files that may already be uploaded ...")
    found = 0
    for n, chunk in enumerate(_chunks(src_ids, 200), 1):
        in_list = "','".join(chunk)
        recs = with_retry(lambda: sf.query_all(
            f"SELECT Id, ContentDocumentId, {SRC_ID_FIELD} FROM ContentVersion "
            f"WHERE {SRC_ID_FIELD} IN ('{in_list}')"))["records"]
        for r in recs:
            i = pos[r[SRC_ID_FIELD]]
            docs.loc[i, ["TargetContentVersionId", "TargetContentDocumentId", "TargetLoadStatus"]] = \
                [r["Id"], r["ContentDocumentId"], "Loaded"]
            found += 1
        if n % 10 == 0:
            log.info(f"  checked {min(n * 200, len(src_ids))}/{len(src_ids)}")
    if found:
        log.info(f"Reconciled {found} files already present in target (no re-upload).")
    return docs


def resolve_document_ids(sf, docs):
    """ContentVersion Id -> ContentDocumentId (the insert response only returns the version id)."""
    need = docs.index[(docs["TargetContentVersionId"] != "") & (docs["TargetContentDocumentId"] == "")]
    if len(need) == 0:
        return docs
    vmap = {}
    for chunk in _chunks(docs.loc[need, "TargetContentVersionId"].tolist(), 200):
        in_list = "','".join(chunk)
        recs = with_retry(lambda: sf.query_all(
            f"SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN ('{in_list}')"))["records"]
        vmap.update({r["Id"]: r["ContentDocumentId"] for r in recs})
    docs.loc[need, "TargetContentDocumentId"] = docs.loc[need, "TargetContentVersionId"].map(vmap).fillna("")
    ok = docs.loc[need, "TargetContentDocumentId"] != ""
    docs.loc[need[ok.values], "TargetLoadStatus"] = "Loaded"
    log.info(f"Resolved ContentDocumentId for {ok.sum()} files.")
    return docs


def upload_versions(sf, engine, limit=None, workers=WORKERS):
    """Step 1. `limit` = max files this run (use a small number for the first test)."""
    _check_target(sf)
    docs = _read(_docs_path())
    links = _read(_links_path())

    # files that failed extraction can't be loaded - list them so they can be re-extracted
    bad = docs[docs["DownloadStatus"] != "Downloaded"]
    if len(bad):
        bad_path = os.path.join(BASE_DIR, "not_loadable_download_failed.csv")
        bad[["SourceContentDocumentId", "SourceContentVersionId", "Title", "DownloadStatus", "DownloadError"]] \
            .to_csv(bad_path, index=False)
        log.warning(f"{len(bad)} files were not downloaded at extraction and are skipped -> {bad_path}")

    todo = docs[(docs["DownloadStatus"] == "Downloaded") & (docs["TargetContentVersionId"] == "")]
    if ONLY_IF_LINKABLE:
        linkable = set(links.loc[links["TargetLinkStatus"] == "ReadyToLink", "SourceContentDocumentId"])
        skipped = (~todo["SourceContentDocumentId"].isin(linkable)).sum()
        todo = todo[todo["SourceContentDocumentId"].isin(linkable)]
        log.info(f"{skipped} files held back: no parent in target yet, or already on their target parent "
                 f"(run map_target_entities / flag_already_in_target again after more data loads).")
    if limit:
        todo = todo.head(limit)

    docs = reconcile_from_target(sf, docs, todo.index)
    todo = todo[docs.loc[todo.index, "TargetContentVersionId"] == ""]
    log.info(f"Uploading {len(todo)} files with {workers} workers ...")

    user_map = _load_user_map(engine) if PRESERVE_AUDIT_FIELDS else {}
    if PRESERVE_AUDIT_FIELDS and CREATED_BY_MODE == "with_owner" and len(todo):
        unmapped = (~todo["SourceCreatedById"].isin(user_map)).sum()
        log.info(f"{unmapped} of {len(todo)} files have a creator with no match in sfrhd.User - "
                 f"those will be created as the integration user.")
    rows = []
    for idx, r in todo.iterrows():
        d = r.to_dict()
        d["_idx"] = idx
        rows.append(d)

    done = 0
    errors = []
    t0 = time.time()
    ex = ThreadPoolExecutor(max_workers=workers)
    try:
        futures = [ex.submit(_upload_one, sf, r, user_map) for r in rows]
        for fut in as_completed(futures):
            res = fut.result()
            i = res["idx"]
            if res["status"] == "Uploaded":
                docs.at[i, "TargetContentVersionId"] = res["version_id"]
                docs.at[i, "TargetLoadStatus"] = "Uploaded"
                if len(rows) <= 100:
                    log.info(f"Uploaded {docs.at[i, 'OriginalFileName']} ({docs.at[i, 'ContentSize']} bytes)")
            else:
                docs.at[i, "TargetLoadStatus"] = res["status"]
                errors.append({"SourceContentDocumentId": docs.at[i, "SourceContentDocumentId"],
                               "OriginalFileName": docs.at[i, "OriginalFileName"],
                               "Status": res["status"], "Error": res["error"]})
                log.error(f"{res['status']}: {docs.at[i, 'OriginalFileName']} - {res['error'][:400]}")
            done += 1
            if done % 100 == 0:
                rate = done / (time.time() - t0)
                log.info(f"{done}/{len(rows)} done ({rate:.1f} files/s)")
            if done % CHECKPOINT_EVERY == 0:
                _save(docs, _docs_path())
    except KeyboardInterrupt:
        log.warning("Interrupted - cancelling queued uploads and saving progress ...")
        ex.shutdown(wait=True, cancel_futures=True)
    finally:
        ex.shutdown(wait=True)
        docs = resolve_document_ids(sf, docs)
        _save(docs, _docs_path())
        if errors:
            err_path = os.path.join(BASE_DIR, "load_errors.csv")
            pd.DataFrame(errors).to_csv(err_path, index=False, encoding="utf-8-sig")
            log.warning(f"{len(errors)} files failed this run -> {err_path}")

    log.info("Upload status now:\n" + docs["TargetLoadStatus"].value_counts().to_string())
    return docs


# ----------------------------- Step 2: links ----------------------------------
def create_links(sf, batch=200):
    """Step 2. One ContentDocumentLink per mapped link row, 200 per API call (composite sObjects)."""
    _check_target(sf)
    docs = _read(_docs_path())
    links = _read(_links_path())
    docs = resolve_document_ids(sf, docs)
    _save(docs, _docs_path())

    doc_map = dict(zip(docs["SourceContentDocumentId"], docs["TargetContentDocumentId"]))
    todo = links[links["TargetLinkStatus"].isin(["ReadyToLink", "Failed"]) & (links["TargetLinkedEntityId"] != "")]
    todo = todo[todo["SourceContentDocumentId"].map(doc_map).fillna("") != ""]
    log.info(f"Creating {len(todo)} links ...")

    n_ok = n_fail = 0
    for chunk in _chunks(todo.index, batch):
        recs = []
        for i in chunk:
            r = links.loc[i]
            recs.append({"attributes": {"type": "ContentDocumentLink"},
                         "ContentDocumentId": doc_map[r["SourceContentDocumentId"]],
                         "LinkedEntityId": r["TargetLinkedEntityId"],
                         "ShareType": r["ShareType"] or "V",
                         "Visibility": r["Visibility"] or "AllUsers"})
        payload = json.dumps({"allOrNone": False, "records": recs})
        results = with_retry(lambda: sf.restful("composite/sobjects", method="POST", data=payload))

        dups = []
        for i, rr in zip(chunk, results):
            if rr.get("success"):
                links.at[i, "TargetContentDocumentLinkId"] = rr["id"]
                links.at[i, "TargetContentDocumentId"] = doc_map[links.at[i, "SourceContentDocumentId"]]
                links.at[i, "TargetLinkStatus"] = "Linked"
                links.at[i, "TargetLinkError"] = ""
                n_ok += 1
            else:
                err = "; ".join(f"{e.get('statusCode')}: {e.get('message')}" for e in rr.get("errors", []))
                if "DUPLICATE_VALUE" in err:
                    dups.append((i, err))        # don't assume - verify below
                else:
                    links.at[i, "TargetLinkStatus"] = "Failed"
                    links.at[i, "TargetLinkError"] = err[:500]
                    n_fail += 1

        if dups:
            existing = _existing_links(sf, {doc_map[links.at[i, "SourceContentDocumentId"]] for i, _ in dups})
            for i, err in dups:
                key = (doc_map[links.at[i, "SourceContentDocumentId"]], links.at[i, "TargetLinkedEntityId"])
                if key in existing:              # the link really is there
                    links.at[i, "TargetContentDocumentLinkId"] = existing[key]
                    links.at[i, "TargetContentDocumentId"] = key[0]
                    links.at[i, "TargetLinkStatus"] = "Linked"
                    links.at[i, "TargetLinkError"] = "link already existed"
                    n_ok += 1
                else:                            # Salesforce said duplicate but no such link exists
                    links.at[i, "TargetLinkStatus"] = "Failed"
                    links.at[i, "TargetLinkError"] = err[:500]
                    n_fail += 1
        if (n_ok + n_fail) % 2000 < batch:
            _save(links, _links_path())
            log.info(f"{n_ok} linked, {n_fail} failed so far")

    _save(links, _links_path())
    log.info(f"Links done: {n_ok} linked, {n_fail} failed.")
    if n_fail:
        top = links.loc[links["TargetLinkStatus"] == "Failed", ["LinkedEntityType", "TargetLinkError"]]
        log.info("Top link errors:\n" + top.value_counts().head(10).to_string())
    return links


def _existing_links(sf, doc_ids):
    """{(ContentDocumentId, LinkedEntityId): ContentDocumentLinkId} for the given target documents."""
    found = {}
    for chunk in _chunks(sorted(doc_ids), 200):
        in_list = "','".join(chunk)
        recs = with_retry(lambda: sf.query_all(
            f"SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink "
            f"WHERE ContentDocumentId IN ('{in_list}')"))["records"]
        for r in recs:
            found[(r["ContentDocumentId"], r["LinkedEntityId"])] = r["Id"]
    return found


def report_possible_duplicates(sf, out_name="possible_duplicates.csv"):
    """
    READ-ONLY report. For every mapped link row, list the files that ALREADY sit on that target parent
    record (e.g. from an earlier migration) and flag the ones that look like the same file
    (same title + extension + size). Files created by this loader are excluded.
    """
    docs = _read(_docs_path())
    links = _read(_links_path())
    ours = {d for d in docs["TargetContentDocumentId"] if d}

    mapped = links[links["TargetLinkedEntityId"] != ""]
    parents = sorted(set(mapped["TargetLinkedEntityId"]))
    log.info(f"Checking {len(parents)} target parent records for files already attached ...")

    existing = []
    for n, chunk in enumerate(_chunks(parents, 200), 1):
        in_list = "','".join(chunk)
        recs = with_retry(lambda: sf.query_all(
            "SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, "
            "ContentDocument.ContentSize, ContentDocument.CreatedDate FROM ContentDocumentLink "
            f"WHERE LinkedEntityId IN ('{in_list}')"))["records"]
        for r in recs:
            if r["ContentDocumentId"] in ours:
                continue
            cd = r["ContentDocument"]
            existing.append({"LinkedEntityId": r["LinkedEntityId"], "ExistingDocumentId": r["ContentDocumentId"],
                             "ExistingTitle": cd["Title"] or "", "ExistingExt": cd["FileExtension"] or "",
                             "ExistingSize": str(cd["ContentSize"]), "ExistingCreated": cd["CreatedDate"]})
        if n % 10 == 0:
            log.info(f"  checked {min(n * 200, len(parents))}/{len(parents)} parents")

    if not existing:
        log.info("No pre-existing files found on any mapped parent.")
        return pd.DataFrame()

    ex = pd.DataFrame(existing)
    src = mapped.merge(docs[["SourceContentDocumentId", "Title", "FileExtension", "ContentSize"]],
                       on="SourceContentDocumentId", how="left")
    rep = src.merge(ex, left_on="TargetLinkedEntityId", right_on="LinkedEntityId", how="inner")
    rep["LooksSame"] = ((rep["Title"].str.lower() == rep["ExistingTitle"].str.lower()) &
                        (rep["FileExtension"].str.lower() == rep["ExistingExt"].str.lower()) &
                        (rep["ContentSize"] == rep["ExistingSize"]))
    keep = ["SourceContentDocumentId", "LinkedEntityType", "SourceLinkedEntityId", "TargetLinkedEntityId",
            "Title", "FileExtension", "ContentSize", "ExistingDocumentId", "ExistingTitle", "ExistingExt",
            "ExistingSize", "ExistingCreated", "LooksSame"]
    rep = rep[keep].sort_values(["LooksSame", "LinkedEntityType"], ascending=[False, True])
    out = os.path.join(BASE_DIR, out_name)
    rep.to_csv(out, index=False, encoding="utf-8-sig")

    same = rep[rep["LooksSame"]]
    log.info(f"{len(rep)} existing-file/parent pairs; {same['SourceContentDocumentId'].nunique()} source files "
             f"already look present on their parent -> {out}")
    print(same.groupby("LinkedEntityType")["SourceContentDocumentId"].nunique().to_string())
    return rep


def _norm(series):
    return series.fillna("").astype(str).str.strip().str.lower()


def flag_already_in_target(sf, require_size=True, out_name="target_overlap_report.csv"):
    """
    Run AFTER map_target_entities and BEFORE upload_versions.

    For every ReadyToLink row, look at the files already attached to the target parent record (e.g. from the
    2024 migration). If the same file is already there (title + extension + size) the row is set to
    AlreadyInTarget: it will not be uploaded or linked again. Re-running re-evaluates, so a row flips back to
    ReadyToLink if the matching file is no longer there.

    Matching is count-aware: if the source has two identical files on a parent and the target has one,
    only one is flagged. With require_size=True, same-name files whose size differs are NOT skipped; they are
    listed in the report as NameMatchSizeDiffers so you can review them.
    Files created by this loader are ignored when looking at what is "already there".
    """
    docs = _read(_docs_path())
    links = _read(_links_path())
    ours = {d for d in docs["TargetContentDocumentId"] if d}

    ev = links[links["TargetLinkStatus"].isin(["ReadyToLink", "AlreadyInTarget"]) &
               (links["TargetLinkedEntityId"] != "")].copy()
    ev["_li"] = ev.index
    parents = sorted(set(ev["TargetLinkedEntityId"]))
    log.info(f"Checking {len(parents)} target parent records for files already attached ...")

    rows, ours_hits = [], 0
    for n, chunk in enumerate(_chunks(parents, 200), 1):
        in_list = "','".join(chunk)
        recs = with_retry(lambda: sf.query_all(
            "SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, "
            "ContentDocument.ContentSize FROM ContentDocumentLink "
            f"WHERE LinkedEntityId IN ('{in_list}')"))["records"]
        for r in recs:
            if r["ContentDocumentId"] in ours:
                ours_hits += 1
                continue
            cd = r["ContentDocument"]
            rows.append({"parent": r["LinkedEntityId"], "title": cd["Title"], "ext": cd["FileExtension"],
                         "size": cd["ContentSize"], "doc": r["ContentDocumentId"]})
        if n % 10 == 0:
            log.info(f"  checked {min(n * 200, len(parents))}/{len(parents)} parents")
    if ours_hits:
        log.info(f"{ours_hits} files on these parents were created by this loader (ignored).")

    ex = pd.DataFrame(rows, columns=["parent", "title", "ext", "size", "doc"])
    ex["title"], ex["ext"] = _norm(ex["title"]), _norm(ex["ext"])
    ex["size"] = ex["size"].astype(str).str.strip()

    src = ev[["_li", "SourceContentDocumentId", "LinkedEntityType", "TargetLinkedEntityId"]].merge(
        docs[["SourceContentDocumentId", "Title", "FileExtension", "ContentSize"]],
        on="SourceContentDocumentId", how="left")
    src["parent"] = src["TargetLinkedEntityId"]
    src["title"], src["ext"] = _norm(src["Title"]), _norm(src["FileExtension"])
    src["size"] = src["ContentSize"].astype(str).str.strip()

    keys = ["parent", "title", "ext"] + (["size"] if require_size else [])
    cnt = ex.groupby(keys).size().rename("n_exist").reset_index()
    src = src.merge(cnt, on=keys, how="left")
    src["n_exist"] = src["n_exist"].fillna(0)
    src = src.sort_values("SourceContentDocumentId")
    src["_k"] = src.groupby(keys).cumcount()
    src["already"] = src["_k"] < src["n_exist"]

    hit = src.loc[src["already"], "_li"]
    links.loc[hit, "TargetLinkStatus"] = "AlreadyInTarget"
    links.loc[hit, "TargetLinkError"] = "same file already on target parent"
    back = src.loc[~src["already"], "_li"]
    flip = back[links.loc[back, "TargetLinkStatus"].eq("AlreadyInTarget").values]
    links.loc[flip, ["TargetLinkStatus", "TargetLinkError"]] = ["ReadyToLink", ""]

    out_rows = src[src["already"]].assign(Outcome="AlreadyInTarget")
    if require_size and len(ex):
        nm = ex.groupby(["parent", "title", "ext"]).size().rename("n_name").reset_index()
        near = src[~src["already"]].merge(nm, on=["parent", "title", "ext"], how="inner")
        out_rows = pd.concat([out_rows, near.assign(Outcome="NameMatchSizeDiffers")])
    cols = ["Outcome", "SourceContentDocumentId", "LinkedEntityType", "TargetLinkedEntityId",
            "Title", "FileExtension", "ContentSize"]
    out = os.path.join(BASE_DIR, out_name)
    out_rows[cols].to_csv(out, index=False, encoding="utf-8-sig")
    _save(links, _links_path())

    n_near = int((out_rows["Outcome"] == "NameMatchSizeDiffers").sum())
    log.info(f"{int(src['already'].sum())} links flagged AlreadyInTarget; "
             f"{int((~src['already']).sum())} remain ReadyToLink; "
             f"{n_near} same-name/different-size files left to load (review) -> {out}")
    print(src[src["already"]].groupby("LinkedEntityType").size().to_string())
    return out_rows[cols]


def remove_unneeded_uploads(sf, dry_run=True):
    """
    Clean-up for files this loader already uploaded whose EVERY link turned out to be AlreadyInTarget
    (e.g. pilot files that duplicate the 2024 copies). Deletes only files from this manifest, and never one
    that is linked to anything other than a user. dry_run=True just lists them.
    """
    docs = _read(_docs_path())
    links = _read(_links_path())
    st = links.groupby("SourceContentDocumentId")["TargetLinkStatus"].agg(set)
    up = docs[docs["TargetContentDocumentId"] != ""]
    cand = up[up["SourceContentDocumentId"].map(lambda d: st.get(d) == {"AlreadyInTarget"})]
    if cand.empty:
        log.info("No unneeded uploads found.")
        return cand

    linked = _existing_links(sf, set(cand["TargetContentDocumentId"]))
    unsafe = {d for (d, e) in linked if not e.startswith("005")}   # linked to a real record -> leave alone
    cand = cand[~cand["TargetContentDocumentId"].isin(unsafe)]
    log.info(f"{len(cand)} uploaded files are not needed ({len(unsafe)} skipped because they are linked to records).")
    if dry_run:
        print(cand[["OriginalFileName", "TargetContentDocumentId"]].to_string())
        log.info("dry_run=True - nothing deleted. Call remove_unneeded_uploads(sf, dry_run=False) to delete.")
        return cand

    _check_target(sf)
    for i, r in cand.iterrows():
        with_retry(lambda: sf.ContentDocument.delete(r["TargetContentDocumentId"]))
        docs.loc[i, ["TargetContentVersionId", "TargetContentDocumentId", "TargetLoadStatus"]] = ["", "", "Pending"]
    _save(docs, _docs_path())
    log.info(f"Deleted {len(cand)} unneeded files from target and reset them to Pending.")
    return cand


def diagnose_upload(sf, engine, original_file_name):
    """
    Uploads ONE small file several ways to find which field makes Salesforce reject it:
      1 minimal | 2 + external id | 3 + CreatedDate | 4 + CreatedById only | 5 + CreatedById + OwnerId | 6 all
    Prints the full Salesforce error for each variant. Every test file it creates is deleted again.
    Pick a small file that failed, e.g. diagnose_upload(sf, engine, "ASIC.pdf").
    """
    _check_target(sf)
    docs = _read(_docs_path())
    row = docs[(docs["OriginalFileName"] == original_file_name) & (docs["DownloadStatus"] == "Downloaded")].iloc[0]
    with open(local_path(row["CanonicalRelativePath"]), "rb") as f:
        base = {"Title": row["Title"] or row["OriginalFileName"], "PathOnClient": row["OriginalFileName"],
                "VersionData": base64.b64encode(f.read()).decode("ascii")}

    user_map = _load_user_map(engine)
    # each variant gets its own test value: the external-id field is usually Unique, and the test files
    # from earlier variants still exist while later ones run
    ext = (lambda tag: {SRC_ID_FIELD: f"DIAG-{tag}-{row['SourceContentVersionId']}"}) if SRC_ID_FIELD else (lambda tag: None)
    created_date = {"CreatedDate": row["SourceCreatedDate"]} if row["SourceCreatedDate"] else None
    uid = user_map.get(row["SourceCreatedById"])
    created_by = {"CreatedById": uid} if uid else None
    created_by_owner = {"CreatedById": uid, "OwnerId": uid} if uid else None
    variants = {"1 minimal": {}, "2 + external id": ext("v2"), "3 + CreatedDate": created_date,
                "4 + CreatedById only": created_by,
                "5 + CreatedById + OwnerId": created_by_owner,
                "6 everything (loader)": {k: v for x in (ext("v6"), created_date, created_by_owner) if x
                                          for k, v in x.items()}}

    print(f"File: {original_file_name} ({row['ContentSize']} bytes), source creator {row['SourceCreatedById']} "
          f"-> target user {user_map.get(row['SourceCreatedById'], 'NOT MAPPED')}")
    made = []
    for name, extra in variants.items():
        if extra is None:
            print(f"{name:26s} skipped (nothing to add)")
            continue
        try:
            out = sf.ContentVersion.create({**base, **extra})
            made.append(out["id"])
            print(f"{name:26s} OK  {out['id']}")
        except Exception as e:  # noqa
            print(f"{name:26s} FAILED  {getattr(e, 'content', None) or e}")

    for k in range(0, len(made), 200):
        in_list = "','".join(made[k:k + 200])
        for r in sf.query_all(f"SELECT ContentDocumentId FROM ContentVersion WHERE Id IN ('{in_list}')")["records"]:
            sf.ContentDocument.delete(r["ContentDocumentId"])
    if made:
        print(f"Deleted {len(made)} test file(s) again.")


def diagnose_link(sf, engine):
    """
    Finds out WHY links fail with INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY. For one failed link per parent
    type it uploads two tiny test files and tries to link each to that parent record:
        A  owned by the integration user (the user running this code)
        B  owned by the original creator's target user (what the loader does with CREATED_BY_MODE="with_owner")
    A fails too            -> the integration user has no access to the PARENT RECORD
    A works, B fails       -> the problem is FILE OWNERSHIP (use CREATED_BY_MODE="off" or grant Modify All Data)
    Test files are deleted afterwards (if one can't be deleted its Id is printed).
    """
    _check_target(sf)
    docs = _read(_docs_path())
    links = _read(_links_path())
    failed = links[links["TargetLinkStatus"] == "Failed"]
    if failed.empty:
        print("No failed links.")
        return
    user_map = _load_user_map(engine)
    creator = dict(zip(docs["SourceContentDocumentId"], docs["SourceCreatedById"]))
    body = base64.b64encode(b"link diagnostic").decode("ascii")
    made = []

    def make(extra):
        out = sf.ContentVersion.create({"Title": "DIAG link test", "PathOnClient": "diag_link_test.txt",
                                        "VersionData": body, **extra})
        r = sf.query("SELECT ContentDocumentId, Owner.Name, CreatedBy.Username, CreatedBy.Profile.Name "
                     f"FROM ContentVersion WHERE Id = '{out['id']}'")["records"][0]
        made.append(r["ContentDocumentId"])
        return r

    def link(doc_id, entity_id):
        payload = json.dumps({"allOrNone": False, "records": [{
            "attributes": {"type": "ContentDocumentLink"}, "ContentDocumentId": doc_id,
            "LinkedEntityId": entity_id, "ShareType": "V", "Visibility": "AllUsers"}]})
        r = sf.restful("composite/sobjects", method="POST", data=payload)[0]
        return "OK" if r.get("success") else "; ".join(f"{e['statusCode']}: {e['message']}" for e in r["errors"])

    try:
        for etype, grp in failed.groupby("LinkedEntityType"):
            row = grp.iloc[0]
            ent = row["TargetLinkedEntityId"]
            print(f"\n=== {etype}  {ent}  ({len(grp)} failed links of this type)")
            try:
                o = sf.query(f"SELECT OwnerId, Owner.Name FROM {etype} WHERE Id = '{ent}'")["records"]
                print("   parent record owner:", o[0]["Owner"]["Name"] if o else "NOT VISIBLE to the integration user")
            except Exception as e:  # noqa
                print("   parent record owner: could not read (", str(e)[:80], ")")

            a_res = b_res = None
            ra = make({})
            print(f"   running user: {ra['CreatedBy']['Username']}  (profile {ra['CreatedBy']['Profile']['Name']})")
            a_res = link(ra["ContentDocumentId"], ent)
            print(f"   A file owned by integration user -> {a_res}")

            uid = user_map.get(creator.get(row["SourceContentDocumentId"], ""))
            if uid:
                rb = make({"CreatedById": uid, "OwnerId": uid})
                b_res = link(rb["ContentDocumentId"], ent)
                print(f"   B file owned by {rb['Owner']['Name']} -> {b_res}")
            else:
                print("   B skipped (creator has no target user)")

            if a_res != "OK":
                print("   => PARENT RECORD ACCESS: the integration user cannot attach files to this record.")
            elif b_res not in (None, "OK"):
                print("   => FILE OWNERSHIP: linking only works for files the integration user owns.")
            else:
                print("   => both linked fine; the earlier failure may be specific to that record.")
    finally:
        for d in made:
            try:
                sf.ContentDocument.delete(d)
            except Exception as e:  # noqa
                print(f"   could not delete test file {d}: {str(e)[:100]}")


def check_parents_visible(sf, types=None, mark_unseen=False):
    """
    PRE-FLIGHT: for every target parent Id the manifest wants to link to, ask the org whether the integration user
    can actually see that record. Catches "staging data came from a different org / the record isn't in this
    sandbox / sharing hides it" BEFORE files are uploaded and linking fails.
      types        e.g. ["Case", "Contact"] to check only some parent types (default: all)
      mark_unseen  True -> rows whose parent isn't visible become ParentNotVisible, so they are neither uploaded
                   nor linked; re-running flips them back to ReadyToLink once the parent is visible.
    Writes the missing Ids to parents_not_visible.csv. NOTE: an invisible record is either missing from the org or
    hidden by sharing - this check can't tell which; open one Id in the UI as a full admin to find out.
    """
    links = _read(_links_path())
    ev = links[links["TargetLinkStatus"].isin(["ReadyToLink", "Failed", "ParentNotVisible"]) &
               (links["TargetLinkedEntityId"] != "")]
    if types:
        ev = ev[ev["LinkedEntityType"].isin(types)]

    report, missing_rows = [], []
    for etype, grp in ev.groupby("LinkedEntityType"):
        ids = sorted(set(grp["TargetLinkedEntityId"]))
        seen, ok = set(), True
        for chunk in _chunks(ids, 200):
            in_list = "','".join(chunk)
            try:
                recs = with_retry(lambda: sf.query_all(f"SELECT Id FROM {etype} WHERE Id IN ('{in_list}')"))["records"]
            except Exception as e:  # noqa
                log.warning(f"{etype}: cannot query this object ({str(e)[:100]}) - skipped")
                ok = False
                break
            seen |= {r["Id"] for r in recs}
        if not ok:
            continue

        vis = grp["TargetLinkedEntityId"].isin(seen)
        report.append({"ParentType": etype, "Parents": len(ids), "Visible": len(seen),
                       "NotVisible": len(ids) - len(seen), "PctVisible": round(100 * len(seen) / len(ids), 1),
                       "LinksAffected": int((~vis).sum())})
        for pid in sorted(set(ids) - seen):
            missing_rows.append({"ParentType": etype, "TargetLinkedEntityId": pid,
                                 "Links": int((grp["TargetLinkedEntityId"] == pid).sum())})
        if mark_unseen:
            gone = grp.index[~vis & grp["TargetLinkStatus"].isin(["ReadyToLink", "Failed"])]
            back = grp.index[vis & (grp["TargetLinkStatus"] == "ParentNotVisible")]
            links.loc[gone, ["TargetLinkStatus", "TargetLinkError"]] = \
                ["ParentNotVisible", "parent record not visible to the integration user in this org"]
            links.loc[back, ["TargetLinkStatus", "TargetLinkError"]] = ["ReadyToLink", ""]

    rep = pd.DataFrame(report)
    if rep.empty:
        log.info("Nothing to check.")
        return rep
    print(rep.sort_values("NotVisible", ascending=False).to_string(index=False))
    if missing_rows:
        out = os.path.join(BASE_DIR, "parents_not_visible.csv")
        pd.DataFrame(missing_rows).to_csv(out, index=False)
        log.info(f"{len(missing_rows)} parent Ids not visible -> {out}")
    if mark_unseen:
        _save(links, _links_path())
        log.info("Link rows updated (ParentNotVisible / ReadyToLink).")
    return rep


def prepare_for_new_target(docs_out="content_documents_prod.csv", links_out="content_document_links_prod.csv"):
    """
    Start a load into a DIFFERENT org (e.g. production after a sandbox rehearsal) without touching the sandbox
    results. Copies the current manifests and wipes everything that belongs to the old target: target Ids, link
    mappings and statuses. Refuses to overwrite existing output files, so re-running it can never erase real
    progress. Afterwards point the loader at the copies:
        lcd.DOCS_FILE, lcd.LINKS_FILE = docs_out, links_out
    and run map_target_entities -> flag_already_in_target again so everything is evaluated against the new org.
    """
    for f in (docs_out, links_out):
        if os.path.exists(os.path.join(BASE_DIR, f)):
            raise FileExistsError(f"{f} already exists - delete it yourself if you really want to start over.")
    docs = _read(_docs_path())
    links = _read(_links_path())
    for c in ("TargetContentVersionId", "TargetContentDocumentId"):
        docs[c] = ""
    docs["TargetLoadStatus"] = "Pending"
    for c in ("TargetLinkedEntityId", "TargetOwnerId", "TargetContentVersionId", "TargetContentDocumentId",
              "TargetContentDocumentLinkId", "TargetLinkError"):
        if c in links.columns:
            links[c] = ""
    links["TargetLinkStatus"] = "PendingTargetMapping"
    _save(docs, os.path.join(BASE_DIR, docs_out))
    _save(links, os.path.join(BASE_DIR, links_out))
    log.info(f"Created {docs_out} ({len(docs)} files) and {links_out} ({len(links)} links), all target state cleared. "
             f"Now set lcd.DOCS_FILE = '{docs_out}' and lcd.LINKS_FILE = '{links_out}'.")


def rollback_loaded(sf, dry_run=True, limit=None):
    """
    UNDO: deletes from the target every file this manifest recorded as loaded (deleting a file also removes its
    links) and resets those rows to Pending / ReadyToLink so they can be loaded again. Only touches files listed in
    this manifest. dry_run=True just lists them. limit = undo only the first N.
    """
    docs = _read(_docs_path())
    links = _read(_links_path())
    done = docs[docs["TargetContentDocumentId"] != ""]
    if limit:
        done = done.head(limit)
    log.info(f"{len(done)} loaded files would be deleted from {sf.sf_instance}.")
    if dry_run:
        print(done[["OriginalFileName", "TargetContentDocumentId"]].to_string())
        log.info("dry_run=True - nothing deleted. Call rollback_loaded(sf, dry_run=False) to delete.")
        return done
    _check_target(sf)
    for i, r in done.iterrows():
        with_retry(lambda: sf.ContentDocument.delete(r["TargetContentDocumentId"]))
        docs.loc[i, ["TargetContentVersionId", "TargetContentDocumentId", "TargetLoadStatus"]] = ["", "", "Pending"]
        m = links["SourceContentDocumentId"] == r["SourceContentDocumentId"]
        links.loc[m & links["TargetLinkStatus"].isin(["Linked", "Failed"]),
                  ["TargetLinkStatus", "TargetContentDocumentLinkId", "TargetContentDocumentId", "TargetLinkError"]] = \
            ["ReadyToLink", "", "", ""]
    _save(docs, _docs_path())
    _save(links, _links_path())
    log.info(f"Deleted {len(done)} files and reset their rows.")
    return done


# ------------------------------- reporting ------------------------------------
def summary():
    docs = _read(_docs_path())
    links = _read(_links_path())
    print("\nFiles  (TargetLoadStatus):\n" + docs["TargetLoadStatus"].value_counts().to_string())
    print("\nLinks  (TargetLinkStatus):\n" + links["TargetLinkStatus"].value_counts().to_string())
    print("\nLinks not yet linked, by parent type:")
    pending = links[links["TargetLinkStatus"] != "Linked"]
    print(pending.groupby(["LinkedEntityType", "TargetLinkStatus"]).size().to_string())
