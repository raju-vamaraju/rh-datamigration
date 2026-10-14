#!/usr/bin/env python3
import os
import csv
import json
import time
import base64
import hashlib
import argparse
import urllib.parse
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed

import requests
import pyodbc
from simple_salesforce import Salesforce

from datetime import datetime

def sf_datetime(value):
    if not value:
        return None

    # 2026-08-30T04:15:22.000+0000
    try:
        return datetime.strptime(
            value,
            "%Y-%m-%dT%H:%M:%S.%f%z"
        ).replace(tzinfo=None)
    except:
        pass

    # 2026-08-30T04:15:22Z
    try:
        return datetime.strptime(
            value,
            "%Y-%m-%dT%H:%M:%SZ"
        )
    except:
        pass

    raise ValueError(f"Unsupported datetime format: {value}")

def load_env_file(path: str | os.PathLike[str] | None = None) -> None:
    env_path = Path(path) if path else Path(__file__).resolve().parent / ".env"
    if not env_path.exists():
        return

    with env_path.open("r", encoding="utf-8") as fh:
        for raw_line in fh:
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue

            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip()

            if value and value[:1] in {'"', "'"} and value[-1:] == value[:1]:
                value = value[1:-1]

            if " #" in value:
                value = value.split(" #", 1)[0].rstrip()

            if key and os.getenv(key) is None:
                os.environ[key] = value


load_env_file()

# -----------------------------
# Helpers
# -----------------------------
def env(name: str, default: Optional[str] = None) -> str:
    v = os.getenv(name, default)
    if v is None or v == "":
        raise RuntimeError(f"Missing environment variable: {name}")
    return v

def now_ts() -> str:
    # UTC-ish string; SQL Server stores as DATETIME2
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

def ensure_dirs():
    for p in ["data/extracted", "data/blobs", "data/logs"]:
        os.makedirs(p, exist_ok=True)

def sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

# -----------------------------
# MSSQL Connection / Ledger
# -----------------------------
def mssql_conn() -> pyodbc.Connection:
    driver = os.getenv("MSSQL_DRIVER", "ODBC Driver 18 for SQL Server")
    server = os.getenv("MSSQL_SERVER", "localhost,1433")
    database = os.getenv("MSSQL_DATABASE", "SalesforceMigration")
    trust_cert = os.getenv("MSSQL_TRUST_CERT", "yes").lower() in ("1", "true", "yes", "y")

    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "Encrypt=yes;"
        f"TrustServerCertificate={'yes' if trust_cert else 'no'};"
    )

    conn = pyodbc.connect(conn_str, autocommit=False)
    # conn.fast_executemany = True
    return conn

def ledger_init_check():
    """
    Assumes you ran the provided DDL already.
    We just sanity-check the tables exist.
    """
    with mssql_conn() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT COUNT(*) FROM sys.objects
            WHERE object_id = OBJECT_ID('dbo.sf_file_items') AND type = 'U'
        """)
        if cur.fetchone()[0] != 1:
            raise RuntimeError("Missing dbo.sf_file_items. Run the DDL first.")
        cur.execute("""
            SELECT COUNT(*) FROM sys.objects
            WHERE object_id = OBJECT_ID('dbo.sf_file_links') AND type = 'U'
        """)
        if cur.fetchone()[0] != 1:
            raise RuntimeError("Missing dbo.sf_file_links. Run the DDL first.")
        conn.commit()

# -----------------------------
# Parent mapping
# -----------------------------
def load_parent_map(path: str) -> Dict[str, str]:
    m = {}
    with open(path, newline="", encoding="utf-8") as f:
        r = csv.DictReader(f)
        for row in r:
            s = row["source_parent_id"].strip()
            t = row["target_parent_id"].strip()
            if s and t:
                m[s] = t
    return m

# -----------------------------
# Salesforce REST Client
# -----------------------------
@dataclass
class SFSession:
    instance_url: str
    access_token: str
    api_version: str
    username: Optional[str] = None
    password: Optional[str] = None
    security_token: Optional[str] = None
    domain: str = "test"
    _refreshed: bool = False

    def _headers(self, extra: Optional[Dict[str, str]] = None) -> Dict[str, str]:
        h = {"Authorization": f"Bearer {self.access_token}"}
        if extra:
            h.update(extra)
        return h

    def refresh(self) -> None:
        if not self.username or not self.password:
            raise RuntimeError(
                "Salesforce username/password are required to refresh an expired bearer token. "
                "Set SRC_USER/SRC_PASS and TGT_USER/TGT_PASS (and security token if needed)."
            )

        sf = Salesforce(
            username=self.username,
            password=self.password,
            security_token=self.security_token,
            domain=self.domain,
        )
        self.instance_url = sf.sf_instance
        self.access_token = sf.session_id
        self._refreshed = True

    def rest(self, method: str, path: str, *,
             params: Optional[Dict[str, str]] = None,
             headers: Optional[Dict[str, str]] = None,
             json_body=None,
             data=None,
             stream: bool = False,
             timeout: int = 300) -> requests.Response:
        if not self.instance_url.startswith(("http://", "https://")):
            self.instance_url = "https://" + self.instance_url.strip("/")
        url = self.instance_url.rstrip("/") + path
        
        resp = requests.request(
            method, url,
            params=params,
            headers=self._headers(headers),
            json=json_body,
            data=data,
            stream=stream,
            timeout=timeout
        )
        if resp.status_code == 401 and self.username and self.password and not self._refreshed:
            self.refresh()
            resp = requests.request(
                method, url,
                params=params,
                headers=self._headers(headers),
                json=json_body,
                data=data,
                stream=stream,
                timeout=timeout
            )
        return resp

    def query(self, soql: str) -> List[dict]:
        encoded = urllib.parse.quote(soql, safe="")
        path = f"/services/data/v{self.api_version}/query?q={encoded}"
        out: List[dict] = []

        resp = self.rest("GET", path)
        # resp.raise_for_status()
        if not resp.ok:
            print(resp.text)
            resp.raise_for_status()
        payload = resp.json()
        out.extend(payload.get("records", []))

        while not payload.get("done", True):
            next_url = payload["nextRecordsUrl"]
            resp = self.rest("GET", next_url)
            resp.raise_for_status()
            payload = resp.json()
            out.extend(payload.get("records", []))

        return out

    def download_blob(self, url_path: str, dest_path: str) -> None:
        resp = self.rest("GET", url_path, stream=True)
        resp.raise_for_status()
        with open(dest_path, "wb") as f:
            for chunk in resp.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    f.write(chunk)

# -----------------------------
# Extraction (Attachments + Files)
# -----------------------------
def extract_attachments(sf: SFSession, prefixes: List[str], batch_id: str):
    where = " OR ".join([f"ParentId LIKE '{p}%'" for p in prefixes])
    soql = (
        "SELECT Id, ParentId, Name, BodyLength, ContentType, CreatedDate FROM Attachment "
        # f"WHERE {where}"
    )
    records = sf.query(soql)

    extract_run_ts = now_ts()
    items_rows = []
    links_rows = []

    for rec in records:
        att_id = rec["Id"]
        parent_id = rec["ParentId"]
        name = rec.get("Name") or att_id
        mime = rec.get("ContentType")
        size = int(rec.get("BodyLength") or 0)
        created = sf_datetime(rec.get("CreatedDate"))

        # Attachment binary endpoint [2](https://teams.microsoft.com/l/meeting/details?eventId=AAMkAGY3ZTAzMmYwLWZkZDQtNGViZi04NDZiLTY1ZDhkY2NmNDY3YgFRAAgI3p847miAAEYAAAAAVN5N3TwlJE69q-kp-ovd_wcAlOJvO59WGUC6siMYOXSdqwAAAAABDQAAlOJvO59WGUC6siMYOXSdqwAAaaYK5AAAEA%3d%3d)
        download_url = f"/services/data/v{sf.api_version}/sobjects/Attachment/{att_id}/Body"

        file_ext = name.rsplit(".", 1)[-1].lower() if "." in name else None

        items_rows.append((
            "ATTACHMENT", att_id, att_id, created,
            name, file_ext, mime, size, download_url,
            extract_run_ts, batch_id
        ))
        links_rows.append((
            "ATTACHMENT", att_id, parent_id, batch_id
        ))

    with mssql_conn() as conn:
        cur = conn.cursor()
        cur.executemany("""
            INSERT INTO dbo.sf_file_items (
                source_type, source_file_id, source_version_id, source_created_date,
                file_name, file_ext, mime_type, file_size_bytes, download_url,
                extract_run_ts, batch_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, items_rows)

        cur.executemany("""
            INSERT INTO dbo.sf_file_links (
                source_type, source_file_id, source_parent_id, batch_id
            ) VALUES (?, ?, ?, ?)
        """, links_rows)

        conn.commit()

def extract_files(sf: SFSession, prefixes: List[str], batch_id: str):
    where = " OR ".join([f"LinkedEntityId LIKE '{p}%'" for p in prefixes])
    soql_links = (
        "SELECT ContentDocumentId, LinkedEntityId "
        f"FROM ContentDocumentLink WHERE {where}"
    )
    links = sf.query(soql_links)

    extract_run_ts = now_ts()

    # Insert links immediately
    links_rows = [("FILE", l["ContentDocumentId"], l["LinkedEntityId"], batch_id) for l in links]

    doc_ids = sorted({l["ContentDocumentId"] for l in links})

    def chunks(lst, n=200):
        for i in range(0, len(lst), n):
            yield lst[i:i+n]

    items_rows = []
    for part in chunks(doc_ids, 200):
        in_list = ",".join([f"'{d}'" for d in part])
        soql_ver = (
            "SELECT Id, ContentDocumentId, Title, FileExtension, ContentSize, FileType, CreatedDate "
            f"FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN ({in_list})"
        )
        vers = sf.query(soql_ver)

        for v in vers:
            ver_id = v["Id"]
            doc_id = v["ContentDocumentId"]
            title = v.get("Title") or doc_id
            ext = (v.get("FileExtension") or "").lower() or None
            size = int(v.get("ContentSize") or 0)
            ftype = v.get("FileType")
            created = v.get("CreatedDate")

            filename = f"{title}.{ext}" if ext else title

            # Files binary endpoint uses ContentVersion VersionData [3](https://teams.microsoft.com/l/meeting/details?eventId=AAMkAGY3ZTAzMmYwLWZkZDQtNGViZi04NDZiLTY1ZDhkY2NmNDY3YgFRAAgI3sA548IAAEYAAAAAVN5N3TwlJE69q-kp-ovd_wcAlOJvO59WGUC6siMYOXSdqwAAAAABDQAAlOJvO59WGUC6siMYOXSdqwAAaaYK5AAAEA%3d%3d)[4](https://teams.microsoft.com/l/meeting/details?eventId=AAMkAGY3ZTAzMmYwLWZkZDQtNGViZi04NDZiLTY1ZDhkY2NmNDY3YgFRAAgI3rbL5s0AAEYAAAAAVN5N3TwlJE69q-kp-ovd_wcAlOJvO59WGUC6siMYOXSdqwAAAAABDQAAlOJvO59WGUC6siMYOXSdqwAAaaYK5AAAEA%3d%3d)
            download_url = f"/services/data/v{sf.api_version}/sobjects/ContentVersion/{ver_id}/VersionData"

            items_rows.append((
                "FILE", doc_id, ver_id, created,
                filename, ext, ftype, size, download_url,
                extract_run_ts, batch_id
            ))

    with mssql_conn() as conn:
        cur = conn.cursor()
        if links_rows:
            cur.executemany("""
                INSERT INTO dbo.sf_file_links (
                    source_type, source_file_id, source_parent_id, batch_id
                ) VALUES (?, ?, ?, ?)
            """, links_rows)

        if items_rows:
            cur.executemany("""
                INSERT INTO dbo.sf_file_items (
                    source_type, source_file_id, source_version_id, source_created_date,
                    file_name, file_ext, mime_type, file_size_bytes, download_url,
                    extract_run_ts, batch_id
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, items_rows)

        conn.commit()

# -----------------------------
# Download step
# -----------------------------
def download_all(sf: SFSession, batch_id: str, max_workers: int, max_retries: int):
    with mssql_conn() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT item_id, source_type, source_version_id, file_name, download_url
            FROM dbo.sf_file_items
            WHERE batch_id = ?
              AND status IN ('PLANNED','FAILED')
              AND (local_path IS NULL OR sha256 IS NULL)
        """, (batch_id,))
        rows = cur.fetchall()

    def worker(row):
        item_id, source_type, source_version_id, file_name, download_url = row
        safe_name = "".join([c if c.isalnum() or c in "._- " else "_" for c in file_name])[:200]
        local_path = os.path.join("data/blobs", f"{source_type}_{source_version_id}_{safe_name}")

        sf.download_blob(download_url, local_path)
        digest = sha256_file(local_path)
        return item_id, local_path, digest

    def attempt(row):
        tries = 0
        while True:
            tries += 1
            try:
                return worker(row)
            except Exception as e:
                if tries >= max_retries:
                    raise
                time.sleep(1.5 * tries)

    with ThreadPoolExecutor(max_workers=max_workers) as ex:
        futures = {ex.submit(attempt, r): r for r in rows}
        for fut in as_completed(futures):
            r = futures[fut]
            with mssql_conn() as conn:
                cur = conn.cursor()
                try:
                    item_id, local_path, digest = fut.result()
                    cur.execute("""
                        UPDATE dbo.sf_file_items
                        SET local_path = ?, sha256 = ?, status = 'DOWNLOADED', error_message = NULL
                        WHERE item_id = ?
                    """, (local_path, digest, item_id))
                except Exception as e:
                    cur.execute("""
                        UPDATE dbo.sf_file_items
                        SET status = 'FAILED', error_message = ?
                        WHERE item_id = ?
                    """, (str(e), r[0]))
                conn.commit()

# -----------------------------
# Upload step (ContentVersion): base64 vs multipart
# -----------------------------
BASE64_LIMIT_BYTES = int(37.5 * 1024 * 1024)  # non-multipart base64 ceiling [5](https://teams.microsoft.com/l/meeting/details?eventId=AAMkAGY3ZTAzMmYwLWZkZDQtNGViZi04NDZiLTY1ZDhkY2NmNDY3YgFRAAgI3rFLvejAAEYAAAAAVN5N3TwlJE69q-kp-ovd_wcAlOJvO59WGUC6siMYOXSdqwAAAAABDQAAlOJvO59WGUC6siMYOXSdqwAAaaYK5AAAEA%3d%3d)[6](https://teams.microsoft.com/l/meeting/details?eventId=AAMkAGY3ZTAzMmYwLWZkZDQtNGViZi04NDZiLTY1ZDhkY2NmNDY3YgFRAAgI3qS5F0zAAEYAAAAAVN5N3TwlJE69q-kp-ovd_wcAlOJvO59WGUC6siMYOXSdqwAAAAABDQAAlOJvO59WGUC6siMYOXSdqwAAaaYK5AAAEA%3d%3d)

def upload_contentversion_base64(sf_target: SFSession, title: str, path_on_client: str,
                                 first_publish_location_id: Optional[str], file_bytes: bytes) -> Dict:
    payload = {
        "Title": title,
        "PathOnClient": path_on_client,
        "VersionData": base64.b64encode(file_bytes).decode("ascii")
    }
    if first_publish_location_id:
        payload["FirstPublishLocationId"] = first_publish_location_id

    resp = sf_target.rest(
        "POST",
        f"/services/data/v{sf_target.api_version}/sobjects/ContentVersion",
        headers={"Content-Type": "application/json"},
        json_body=payload,
        timeout=600
    )
    if not resp.ok:
        raise RuntimeError(f"Upload base64 failed: {resp.status_code} {resp.text}")
    return resp.json()

def upload_contentversion_multipart(sf_target: SFSession, entity_json: Dict, file_path: str) -> Dict:
    """
    Multipart upload per Salesforce REST 'Insert or Update Blob Data' guidance. [5](https://teams.microsoft.com/l/meeting/details?eventId=AAMkAGY3ZTAzMmYwLWZkZDQtNGViZi04NDZiLTY1ZDhkY2NmNDY3YgFRAAgI3rFLvejAAEYAAAAAVN5N3TwlJE69q-kp-ovd_wcAlOJvO59WGUC6siMYOXSdqwAAAAABDQAAlOJvO59WGUC6siMYOXSdqwAAaaYK5AAAEA%3d%3d)
    NOTE: This example builds the multipart body in memory.
    For many very-large files, implement streaming multipart in your runtime (requests-toolbelt).
    """
    boundary = "boundary_" + hashlib.md5(os.urandom(16)).hexdigest()

    with open(file_path, "rb") as f:
        file_bytes = f.read()

    part1 = (
        f'--{boundary}\r\n'
        'Content-Disposition: form-data; name="entity_content"; charset=UTF-8\r\n'
        'Content-Type: application/json\r\n\r\n'
        f'{json.dumps(entity_json)}\r\n'
    ).encode("utf-8")

    filename = os.path.basename(file_path)
    part2_header = (
        f'--{boundary}\r\n'
        f'Content-Disposition: form-data; name="VersionData"; filename="{filename}"\r\n'
        'Content-Type: application/octet-stream\r\n\r\n'
    ).encode("utf-8")

    closing = f"\r\n--{boundary}--\r\n".encode("utf-8")
    body = part1 + part2_header + file_bytes + closing

    resp = sf_target.rest(
        "POST",
        f"/services/data/v{sf_target.api_version}/sobjects/ContentVersion",
        headers={"Content-Type": f'multipart/form-data; boundary="{boundary}"'},
        data=body,
        timeout=1800
    )
    if not resp.ok:
        raise RuntimeError(f"Upload multipart failed: {resp.status_code} {resp.text}")
    return resp.json()

def upload_all(sf_target: SFSession, parent_map: Dict[str, str], batch_id: str,
               max_workers: int, max_retries: int):
    # Pull DOWNLOADED items
    with mssql_conn() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT item_id, source_type, source_file_id, file_name, file_size_bytes, local_path
            FROM dbo.sf_file_items
            WHERE batch_id = ? AND status = 'DOWNLOADED'
        """, (batch_id,))
        items = cur.fetchall()

        cur.execute("""
            SELECT source_type, source_file_id, COUNT(*) AS cnt
            FROM dbo.sf_file_links
            WHERE batch_id = ?
            GROUP BY source_type, source_file_id
        """, (batch_id,))
        counts = cur.fetchall()

    cnt_map = {(t, fid): c for (t, fid, c) in counts}

    def get_single_target_parent(source_type: str, source_file_id: str) -> Optional[str]:
        # Only if exactly one link exists
        if cnt_map.get((source_type, source_file_id), 0) != 1:
            return None
        with mssql_conn() as conn:
            cur = conn.cursor()
            cur.execute("""
                SELECT TOP 1 source_parent_id
                FROM dbo.sf_file_links
                WHERE batch_id=? AND source_type=? AND source_file_id=?
            """, (batch_id, source_type, source_file_id))
            row = cur.fetchone()
        if not row:
            return None
        return parent_map.get(row[0])

    def worker(row):
        item_id, source_type, source_file_id, file_name, size_bytes, local_path = row
        title = file_name
        path_on_client = file_name
        fpl = get_single_target_parent(source_type, source_file_id)

        if size_bytes <= BASE64_LIMIT_BYTES:
            with open(local_path, "rb") as f:
                file_bytes = f.read()
            resp = upload_contentversion_base64(sf_target, title, path_on_client, fpl, file_bytes)
        else:
            entity = {"Title": title, "PathOnClient": path_on_client}
            if fpl:
                entity["FirstPublishLocationId"] = fpl
            resp = upload_contentversion_multipart(sf_target, entity, local_path)

        target_cv_id = resp["id"]
        # Query ContentDocumentId for this ContentVersion
        q = sf_target.query(f"SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = '{target_cv_id}'")[0]
        return item_id, source_type, source_file_id, target_cv_id, q["ContentDocumentId"]

    def attempt(row):
        tries = 0
        while True:
            tries += 1
            try:
                return worker(row)
            except Exception as e:
                if tries >= max_retries:
                    raise
                time.sleep(2.0 * tries)

    with ThreadPoolExecutor(max_workers=max_workers) as ex:
        futures = {ex.submit(attempt, r): r for r in items}
        for fut in as_completed(futures):
            r = futures[fut]
            with mssql_conn() as conn:
                cur = conn.cursor()
                try:
                    item_id, source_type, source_file_id, target_cv_id, target_cd_id = fut.result()
                    cur.execute("""
                        UPDATE dbo.sf_file_items
                        SET status='UPLOADED',
                            target_content_version_id=?,
                            target_content_document_id=?,
                            upload_run_ts=SYSUTCDATETIME(),
                            error_message=NULL
                        WHERE item_id=?
                    """, (target_cv_id, target_cd_id, item_id))

                    cur.execute("""
                        UPDATE dbo.sf_file_links
                        SET target_content_document_id=?
                        WHERE batch_id=? AND source_type=? AND source_file_id=?
                    """, (target_cd_id, batch_id, source_type, source_file_id))
                except Exception as e:
                    cur.execute("""
                        UPDATE dbo.sf_file_items
                        SET status='FAILED', error_message=?
                        WHERE item_id=?
                    """, (str(e), r[0]))
                conn.commit()

# -----------------------------
# Link step (ContentDocumentLink)
# -----------------------------
def create_link(sf_target: SFSession, content_document_id: str, linked_entity_id: str,
                share_type: str = "V", visibility: str = "AllUsers") -> Dict:
    payload = {
        "ContentDocumentId": content_document_id,
        "LinkedEntityId": linked_entity_id,
        "ShareType": share_type,
        "Visibility": visibility
    }
    resp = sf_target.rest(
        "POST",
        f"/services/data/v{sf_target.api_version}/sobjects/ContentDocumentLink",
        headers={"Content-Type": "application/json"},
        json_body=payload,
        timeout=300
    )
    if not resp.ok:
        raise RuntimeError(f"Link create failed: {resp.status_code} {resp.text}")
    return resp.json()

def link_all(sf_target: SFSession, parent_map: Dict[str, str], batch_id: str,
             max_workers: int, max_retries: int):
    with mssql_conn() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT link_id, source_parent_id, target_content_document_id, share_type, visibility
            FROM dbo.sf_file_links
            WHERE batch_id=? AND status='PLANNED' AND target_content_document_id IS NOT NULL
        """, (batch_id,))
        rows = cur.fetchall()

    def worker(row):
        link_id, src_parent, target_cd_id, share_type, visibility = row
        tgt_parent = parent_map.get(src_parent)
        if not tgt_parent:
            raise RuntimeError(f"No parent mapping for source_parent_id={src_parent}")
        resp = create_link(sf_target, target_cd_id, tgt_parent, share_type, visibility)
        return link_id, tgt_parent, resp["id"]

    def attempt(row):
        tries = 0
        while True:
            tries += 1
            try:
                return worker(row)
            except Exception as e:
                if tries >= max_retries:
                    raise
                time.sleep(1.5 * tries)

    with ThreadPoolExecutor(max_workers=max_workers) as ex:
        futures = {ex.submit(attempt, r): r for r in rows}
        for fut in as_completed(futures):
            r = futures[fut]
            with mssql_conn() as conn:
                cur = conn.cursor()
                try:
                    link_id, tgt_parent, link_sf_id = fut.result()
                    cur.execute("""
                        UPDATE dbo.sf_file_links
                        SET status='LINKED',
                            target_parent_id=?,
                            target_link_id=?,
                            link_run_ts=SYSUTCDATETIME(),
                            error_message=NULL
                        WHERE link_id=?
                    """, (tgt_parent, link_sf_id, link_id))
                except Exception as e:
                    cur.execute("""
                        UPDATE dbo.sf_file_links
                        SET status='FAILED',
                            error_message=?,
                            link_run_ts=SYSUTCDATETIME()
                        WHERE link_id=?
                    """, (str(e), r[0]))
                conn.commit()

# -----------------------------
# Validation / reporting
# -----------------------------
def validate_report(batch_id: str):
    with mssql_conn() as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT
              SUM(CASE WHEN status='UPLOADED' THEN 1 ELSE 0 END) AS uploaded,
              SUM(CASE WHEN status='FAILED' THEN 1 ELSE 0 END) AS failed,
              COUNT(*) AS total,
              SUM(CASE WHEN status='UPLOADED' THEN file_size_bytes ELSE 0 END) AS uploaded_bytes,
              SUM(file_size_bytes) AS total_bytes
            FROM dbo.sf_file_items
            WHERE batch_id=?
        """, (batch_id,))
        items = cur.fetchone()

        cur.execute("""
            SELECT
              SUM(CASE WHEN status='LINKED' THEN 1 ELSE 0 END) AS linked,
              SUM(CASE WHEN status='FAILED' THEN 1 ELSE 0 END) AS failed,
              COUNT(*) AS total
            FROM dbo.sf_file_links
            WHERE batch_id=?
        """, (batch_id,))
        links = cur.fetchone()

    report = {
        "batch_id": batch_id,
        "generated_at": now_ts(),
        "file_items": {
            "uploaded": int(items[0] or 0),
            "failed": int(items[1] or 0),
            "total": int(items[2] or 0),
            "uploaded_bytes": int(items[3] or 0),
            "total_bytes": int(items[4] or 0),
        },
        "file_links": {
            "linked": int(links[0] or 0),
            "failed": int(links[1] or 0),
            "total": int(links[2] or 0),
        }
    }

    out_path = f"data/logs/validation_{batch_id}.json"
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    print(json.dumps(report, indent=2))
    print(f"Wrote: {out_path}")

# -----------------------------
# CLI
# -----------------------------
def main():
    ensure_dirs()
    ledger_init_check()

    parser = argparse.ArgumentParser(description="Governed migration for Salesforce Attachments + Files (MSSQL ledger)")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_extract = sub.add_parser("extract", help="Extract metadata into MSSQL ledger")
    p_extract.add_argument("--batch-id", required=True)
    p_extract.add_argument("--no-attachments", action="store_true")
    p_extract.add_argument("--no-files", action="store_true")

    p_download = sub.add_parser("download", help="Download blobs to disk + hash")
    p_download.add_argument("--batch-id", required=True)

    p_upload = sub.add_parser("upload", help="Upload to target as ContentVersion")
    p_upload.add_argument("--batch-id", required=True)
    p_upload.add_argument("--parent-map", default="parent_id_map.csv")

    p_link = sub.add_parser("link", help="Create ContentDocumentLink relationships")
    p_link.add_argument("--batch-id", required=True)
    p_link.add_argument("--parent-map", default="parent_id_map.csv")

    p_val = sub.add_parser("validate", help="Generate reconciliation report")
    p_val.add_argument("--batch-id", required=True)

    args = parser.parse_args()

    api_version = os.getenv("API_VERSION", "66.0")
    prefixes = os.getenv("LINKED_ENTITY_PREFIXES", "001,003,500,006").split(",")

    max_workers = int(os.getenv("MAX_WORKERS", "4"))
    max_retries = int(os.getenv("MAX_RETRIES", "3"))

    if args.cmd == "extract":
        sf_source = SFSession(
            instance_url=env("SOURCE_INSTANCE_URL"),
            access_token=env("SOURCE_ACCESS_TOKEN"),
            api_version=api_version,
            username=os.getenv("SRC_USER"),
            password=os.getenv("SRC_PASS"),
            security_token=os.getenv("SRC_TOKEN"),
            domain=os.getenv("SRC_DOMAIN", "login"),
        )
        if not args.no_attachments:
            extract_attachments(sf_source, prefixes, args.batch_id)
        # if not args.no_files:
        #     extract_files(sf_source, prefixes, args.batch_id)
        print(f"Extract complete for batch_id={args.batch_id}")

    elif args.cmd == "download":
        sf_source = SFSession(
            instance_url=env("SOURCE_INSTANCE_URL"),
            access_token=env("SOURCE_ACCESS_TOKEN"),
            api_version=api_version,
            username=os.getenv("SRC_USER"),
            password=os.getenv("SRC_PASS"),
            security_token=os.getenv("SRC_TOKEN"),
            domain=os.getenv("SRC_DOMAIN", "login"),
        )
        download_all(sf_source, args.batch_id, max_workers=max_workers, max_retries=max_retries)
        print(f"Download complete for batch_id={args.batch_id}")

    elif args.cmd == "upload":
        sf_target = SFSession(
            instance_url=env("TARGET_INSTANCE_URL"),
            access_token=env("TARGET_ACCESS_TOKEN"),
            api_version=api_version,
            username=os.getenv("TGT_USER"),
            password=os.getenv("TGT_PASS"),
            security_token=os.getenv("TGT_TOKEN"),
            domain=os.getenv("TGT_DOMAIN", "test"),
        )
        parent_map = load_parent_map(args.parent_map)
        upload_all(sf_target, parent_map, args.batch_id, max_workers=max_workers, max_retries=max_retries)
        print(f"Upload complete for batch_id={args.batch_id}")

    elif args.cmd == "link":
        sf_target = SFSession(
            instance_url=env("TARGET_INSTANCE_URL"),
            access_token=env("TARGET_ACCESS_TOKEN"),
            api_version=api_version,
            username=os.getenv("TGT_USER"),
            password=os.getenv("TGT_PASS"),
            security_token=os.getenv("TGT_TOKEN"),
            domain=os.getenv("TGT_DOMAIN", "test"),
        )
        parent_map = load_parent_map(args.parent_map)
        link_all(sf_target, parent_map, args.batch_id, max_workers=max_workers, max_retries=max_retries)
        print(f"Linking complete for batch_id={args.batch_id}")

    elif args.cmd == "validate":
        validate_report(args.batch_id)

if __name__ == "__main__":
    main()
