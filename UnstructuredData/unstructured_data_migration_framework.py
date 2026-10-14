import os
import time
import base64
import hashlib
import logging
import pyodbc
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from simple_salesforce import Salesforce

# =========================================
# CONFIGURATION (use ENV in production)
# =========================================

CONFIG = {
    "batch_size": 20,
    "max_retries": 3,
    "max_workers": 5,
    "throttle_seconds": 2
}

SOURCE_CFG = {
    "username": os.getenv("SRC_USER"),
    "password": os.getenv("SRC_PASS"),
    "security_token": os.getenv("SRC_TOKEN")
}

TARGET_CFG = {
    "username": os.getenv("TGT_USER"),
    "password": os.getenv("TGT_PASS"),
    "security_token": os.getenv("TGT_TOKEN")
}

SQL_CONN_STR = os.getenv("SQL_CONN_STR")

# =========================================
# LOGGING
# =========================================

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

# =========================================
# CONNECTION HELPERS
# =========================================

def get_sql_connection():
    return pyodbc.connect(SQL_CONN_STR)


def connect_sf(cfg):
    return Salesforce(
        username=cfg["username"],
        password=cfg["password"],
        security_token=cfg["security_token"]
    )

# =========================================
# SQL OPERATIONS
# =========================================

def fetch_next_batch(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT TOP (?) *
        FROM FileMigrationLedger
        WHERE Status IN ('Pending','Failed')
          AND RetryCount < ?
        ORDER BY Id
    """, CONFIG["batch_size"], CONFIG["max_retries"])
    return cursor.fetchall()


def mark_in_progress(conn, ids):
    if not ids:
        return

    cursor = conn.cursor()
    cursor.execute(f"""
        UPDATE FileMigrationLedger
        SET Status = 'InProgress',
            UpdatedAt = SYSDATETIME()
        WHERE Id IN ({','.join(map(str, ids))})
    """)
    conn.commit()


def mark_success(conn, row_id, tgt_ver_id, tgt_doc_id):
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE FileMigrationLedger
        SET Status = 'Success',
            TargetContentVersionId = ?,
            TargetContentDocumentId = ?,
            UpdatedAt = SYSDATETIME()
        WHERE Id = ?
    """, tgt_ver_id, tgt_doc_id, row_id)
    conn.commit()


def mark_failure(conn, row_id, error):
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE FileMigrationLedger
        SET Status = 'Failed',
            RetryCount = RetryCount + 1,
            ErrorMessage = ?,
            UpdatedAt = SYSDATETIME()
        WHERE Id = ?
    """, error[:4000], row_id)
    conn.commit()

# =========================================
# SALESFORCE OPERATIONS
# =========================================

def fetch_metadata(sf, content_version_id):
    q = f"""
        SELECT Title, PathOnClient
        FROM ContentVersion
        WHERE Id = '{content_version_id}'
    """
    return sf.query(q)['records'][0]


def download_file(sf, content_version_id):
    url = f"{sf.base_url}sobjects/ContentVersion/{content_version_id}/VersionData"

    with sf.session.get(url, stream=True) as r:
        r.raise_for_status()
        return b"".join(chunk for chunk in r.iter_content(8192))


def upload_file(sf, file_bytes, title, path):
    url = f"{sf.base_url}sobjects/ContentVersion"

    payload = {
        "Title": title,
        "PathOnClient": path,
        "VersionData": base64.b64encode(file_bytes).decode()
    }

    r = sf.session.post(url, json=payload)

    if r.status_code not in (200, 201):
        raise Exception(r.text)

    return r.json()["id"]


def get_content_document_id(sf, content_version_id):
    q = f"""
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = '{content_version_id}'
    """
    return sf.query(q)['records'][0]['ContentDocumentId']


def link_to_parent(sf, doc_id, parent_id):
    payload = {
        "ContentDocumentId": doc_id,
        "LinkedEntityId": parent_id,
        "ShareType": "V"
    }

    res = sf.ContentDocumentLink.create(payload)
    if not res.get("success"):
        raise Exception(f"Link failed: {res}")

# =========================================
# UTILITIES
# =========================================

def compute_hash(data):
    return hashlib.md5(data).hexdigest()


def retry(func):
    def wrapper(*args, **kwargs):
        for attempt in range(CONFIG["max_retries"]):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                if attempt == CONFIG["max_retries"] - 1:
                    raise
                sleep_time = 2 ** attempt
                logging.warning(f"Retrying in {sleep_time}s: {e}")
                time.sleep(sleep_time)
    return wrapper

# =========================================
# CORE PROCESSING
# =========================================

@retry
def process_row(row, sf_src, sf_tgt):
    logging.info(f"Processing {row.SourceContentVersionId}")

    # Step 1: metadata
    meta = fetch_metadata(sf_src, row.SourceContentVersionId)

    # Step 2: download
    file_bytes = download_file(sf_src, row.SourceContentVersionId)

    # Step 3: checksum
    checksum = compute_hash(file_bytes)

    # Step 4: upload
    tgt_version_id = upload_file(
        sf_tgt,
        file_bytes,
        meta["Title"],
        meta["PathOnClient"]
    )

    # Step 5: get doc id
    tgt_doc_id = get_content_document_id(sf_tgt, tgt_version_id)

    # Step 6: link
    if row.TargetParentId:
        link_to_parent(sf_tgt, tgt_doc_id, row.TargetParentId)

    return tgt_version_id, tgt_doc_id, checksum

# =========================================
# BATCH RUNNER
# =========================================

def process_batch():
    conn = get_sql_connection()
    sf_src = connect_sf(SOURCE_CFG)
    sf_tgt = connect_sf(TARGET_CFG)

    rows = fetch_next_batch(conn)

    if not rows:
        logging.info("No work remaining.")
        return False

    ids = [str(r.Id) for r in rows]
    mark_in_progress(conn, ids)

    with ThreadPoolExecutor(max_workers=CONFIG["max_workers"]) as executor:
        future_map = {
            executor.submit(process_row, row, sf_src, sf_tgt): row
            for row in rows
        }

        for future in as_completed(future_map):
            row = future_map[future]

            try:
                tgt_ver, tgt_doc, checksum = future.result()
                mark_success(conn, row.Id, tgt_ver, tgt_doc)
            except Exception as e:
                logging.error(f"Failed row {row.Id}: {e}")
                mark_failure(conn, row.Id, str(e))

    conn.close()
    return True

# =========================================
# MAIN LOOP
# =========================================

def run():
    logging.info("Starting migration engine...")

    while True:
        has_work = process_batch()

        if not has_work:
            logging.info("All work complete.")
            break

        time.sleep(CONFIG["throttle_seconds"])

# =========================================

if __name__ == "__main__":
    run()