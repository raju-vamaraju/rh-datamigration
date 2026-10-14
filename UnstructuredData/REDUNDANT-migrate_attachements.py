import os
import time
import logging
import base64
import pyodbc
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from simple_salesforce import Salesforce


def load_env_file(path: Path | str | None = None) -> None:
    path = Path(path or Path(__file__).parent / ".env")
    if not path.exists():
        return

    with path.open("r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key and os.getenv(key) is None:
                os.environ[key] = value

load_env_file()

# =========================================
# CONFIG
# =========================================

CONFIG = {
    "throttle_seconds": 2,
    "LOG_LEVEL": logging.INFO,
    "MAX_WORKERS": 5,
    "MAX_RETRIES": 3,
    "RETRY_DELAY": 2,
    "CHECKPOINT_FILE": 'migrated_files.txt',
    "BATCH_SIZE": 20    # for query pagination
}

VALID_PARENT_OBJECTS = {
    "Task",
    "EmailTemplate",
    "Assurance_Review__c",
    "Incident_File_Review__c"
}

SQL_CONN_STR = os.getenv("SQL_CONN_STR")

if not SQL_CONN_STR:
    raise RuntimeError(
        "SQL_CONN_STR is not set. Add it to your environment or to UnstructuredDataMigration/.env"
    )

SOURCE_CFG = {
    "username": os.getenv("SRC_USER"),
    "password": os.getenv("SRC_PASS"),
    "security_token": os.getenv("SRC_TOKEN"),
    'instance_url': os.getenv("SRC_URL"),
    'domain': os.getenv("SRC_DOMAIN")
}

TARGET_CFG = {
    "username": os.getenv("TGT_USER"),
    "password": os.getenv("TGT_PASS"),
    "security_token": os.getenv("TGT_TOKEN"),
    'instance_url': os.getenv("TGT_URL"),
    'domain': os.getenv("TGT_DOMAIN")
}

# =========================================
# LOGGING
# =========================================

# logging.basicConfig(level=logging.INFO)
logging.basicConfig(level=CONFIG["LOG_LEVEL"], format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# =========================================
# CONNECTION HELPERS
# =========================================

def connect_sf(cfg):
    return Salesforce(
        username=cfg["username"],
        password=cfg["password"],
        security_token=cfg["security_token"],
        instance_url=cfg["instance_url"],
        domain=cfg["domain"],
        # ,version="59.0"  # specify API version if needed, or leave default
    )

def get_sql_conn():
    return pyodbc.connect(SQL_CONN_STR)

# =========================================
# PREFIX → OBJECT RESOLUTION
# =========================================

def build_prefix_map(sf):
    desc = sf.describe()
    return {
        s['keyPrefix']: s['name']
        for s in desc['sobjects']
        if s.get('keyPrefix')
    }

def resolve_object(prefix_map, sf_id):
    return prefix_map.get(sf_id[:3])

# =========================================
# SQL OPERATIONS
# =========================================

def fetch_batch(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT TOP (?) *
        FROM AttachmentMigrationLedger
        WHERE Status IN ('Pending','Failed')
          AND RetryCount < ?
        ORDER BY Id
    """, CONFIG["BATCH_SIZE"], CONFIG["MAX_RETRIES"])
    return cursor.fetchall()

def mark_in_progress(conn, ids):
    if not ids:
        return
    cursor = conn.cursor()
    cursor.execute(f"""
        UPDATE AttachmentMigrationLedger
        SET Status='InProgress', UpdatedAt=SYSDATETIME()
        WHERE Id IN ({','.join(map(str, ids))})
    """)
    conn.commit()

def mark_success(conn, id, tgt_id):
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE AttachmentMigrationLedger
        SET Status='Success',
            TargetAttachmentId=?,
            UpdatedAt=SYSDATETIME()
        WHERE Id=?
    """, tgt_id, id)
    conn.commit()

def mark_failure(conn, id, err):
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE AttachmentMigrationLedger
        SET Status='Failed',
            RetryCount = RetryCount + 1,
            ErrorMessage=?,
            UpdatedAt=SYSDATETIME()
        WHERE Id=?
    """, err[:4000], id)
    conn.commit()

# =========================================
# SALESFORCE OPERATIONS
# =========================================

def fetch_attachment_metadata(sf, attach_id):
    sfAttr = sf.Attachment.get(attach_id)
    return sfAttr

def download_attachment(sf, body_url):
    # body_url from Salesforce is often a relative path like "/services/data/v59.0/..."
    # Accept either a Salesforce instance or an SFType (resource) object.
    # If passed an SFType, recover the underlying Salesforce instance via `.sf_instance`.
    sf_root = sf
    if not hasattr(sf_root, "instance_url") and hasattr(sf_root, "sf_instance"):
        sf_root = getattr(sf_root, "sf_instance")

    # Ensure body_url is a str
    if not isinstance(body_url, str):
        body_url = str(body_url)

    # Build full URL if necessary
    if not body_url.startswith("http"):
        inst_url = getattr(sf_root, "instance_url", None) or getattr(sf_root, "base_url", None)
        if not inst_url:
            raise RuntimeError("Unable to determine Salesforce instance URL for download")
        body_url = inst_url.rstrip("/") + body_url

    print(f"Downloading from {body_url}")

    resp = sf_root.session.get(body_url, stream=True)
    resp.raise_for_status()
    return resp.content

def upload_attachment(sf, file_bytes, name, parent_id):
    payload = {
        "Name": name,
        "ParentId": parent_id,
        "Body": base64.b64encode(file_bytes).decode()
    }

    res = sf.Attachment.create(payload)

    if not res.get("success"):
        raise Exception(res)

    return res["id"]

# =========================================
# RETRY WRAPPER
# =========================================

def retry(func):
    def wrapper(*args, **kwargs):
        for attempt in range(CONFIG["MAX_RETRIES"]):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                if attempt == CONFIG["MAX_RETRIES"] - 1:
                    raise
                time.sleep(2 ** attempt)
    return wrapper

# =========================================
# CORE PROCESSING
# =========================================

@retry
def process_row(row, sf_src, sf_tgt, prefix_map):

    logging.info(f"Processing attachment {row.SourceAttachmentId}")

    # Step 1: Resolve object type
    obj_type = resolve_object(prefix_map, row.SourceParentId)

    if obj_type not in VALID_PARENT_OBJECTS:
        raise Exception(f"Unsupported parent object: {obj_type}")

    if not row.TargetParentId:
        raise Exception("Missing TargetParentId")

    # Step 2: Fetch metadata
    meta = fetch_attachment_metadata(sf_src, row.SourceAttachmentId)

    # Step 3: Download binary
    file_bytes = download_attachment(sf_src, meta["Body"])

    # Step 4: Upload
    new_id = upload_attachment(
        sf_tgt,
        file_bytes,
        meta["Name"],
        row.TargetParentId
    )

    return new_id

# =========================================
# BATCH PROCESSOR
# =========================================

def process_batch():
    conn = get_sql_conn()

    sf_src = connect_sf(SOURCE_CFG)
    sf_tgt = connect_sf(TARGET_CFG)

    prefix_map = build_prefix_map(sf_src)

    rows = fetch_batch(conn)

    if not rows:
        logging.info("No work remaining")
        return False

    ids = [str(r.Id) for r in rows]
    mark_in_progress(conn, ids)

    with ThreadPoolExecutor(max_workers=CONFIG["MAX_WORKERS"]) as executor:
        futures = {
            executor.submit(process_row, row, sf_src, sf_tgt, prefix_map): row
            for row in rows
        }

        for future in as_completed(futures):
            row = futures[future]
            try:
                tgt_id = future.result()
                mark_success(conn, row.Id, tgt_id)
            except Exception as e:
                logging.error(f"Error for {row.Id}: {e}")
                mark_failure(conn, row.Id, str(e))

    conn.close()
    return True

def migrate_attachment(sf_src, sf_tgt, attachment_id, target_parent_id):
    
    # Step 1: Fetch metadata
    meta = sf_src.Attachment.get(attachment_id)

    # Step 2: Download binary
    body_url = meta['Body']
    file_bytes = sf_src.session.get(body_url).content

    # Step 3: Upload as ContentVersion
    payload = {
        "Title": meta["Name"],
        "PathOnClient": meta["Name"],
        "VersionData": base64.b64encode(file_bytes).decode(),
        "FirstPublishLocationId": target_parent_id
    }

    res = sf_tgt.session.post(
        f"{sf_tgt.base_url}sobjects/ContentVersion",
        json=payload
    )

    return res.json()["id"]

# =========================================
# MAIN LOOP
# =========================================

def run():
    logging.info("Starting attachment migration...")

    while True:
        has_work = process_batch()
        if not has_work:
            break
        time.sleep(CONFIG["THROTTLE_SECONDS"])

# =========================================

if __name__ == "__main__":
    run()