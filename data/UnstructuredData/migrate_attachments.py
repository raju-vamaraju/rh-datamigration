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
    "MAX_WORKERS": 5,   # 1 for debugging, 5 for normal run
    "MAX_RETRIES": 5,
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
    """Fetch attachment metadata - returns dict with proper values."""
    # FIX: .get() returns an SFType-like object, but we can access attributes directly
    attachment = sf.Attachment.get(attach_id)
    
    # Convert to a regular dict to avoid SFType issues
    return {
        'Id': attachment['Id'],
        'Name': attachment['Name'],
        'Body': attachment['Body'],  # This is the URL string, but needs extraction
        'ContentType': attachment.get('ContentType', 'application/octet-stream'),
        'ParentId': attachment['ParentId'],
        'IsPrivate': attachment.get('IsPrivate', False),
        'Description': attachment.get('Description', '')
    }

def download_attachment(sf, attachment_record):
    """
    Download attachment binary data.
    FIX: Handle the Body field correctly - it can be a URL or an SFType object.
    """
    # Get the body URL - this is the critical fix
    body_field = attachment_record['Body']
    
    # FIX: If body_field is an SFType object (has attributes but not string methods)
    # we need to extract the actual URL string
    if hasattr(body_field, 'rstrip'):
        # It's already a string
        body_url = body_field
    else:
        # It might be an SFType object - convert to string or access the URL attribute
        body_url = str(body_field) if body_field else None
        
        # Alternative approach: the Body field from Attachment.get() is actually
        # a relative URL that can be accessed directly
        if not body_url or not body_url.startswith('/'):
            # Construct the URL manually
            if hasattr(sf.instance_url, 'rstrip'):
                instance_url = sf.instance_url.rstrip('/')
            else:
                instance_url = str(sf.instance_url) if sf.instance_url else None

            body_url = f"{instance_url}/services/data/v{sf.version}/sobjects/Attachment/{attachment_record['Id']}/body"
    
    if not body_url:
        raise RuntimeError(f"Could not determine Body URL for attachment {attachment_record['Id']}")
    
    # Ensure we have a full URL
    if not body_url.startswith('http'):
        if hasattr(sf.instance_url, 'rstrip'):
            instance_url = sf.instance_url.rstrip('/')
        else:
            instance_url = f"https://{sf.sf_instance}" if sf.instance_url else None
        if not body_url.startswith('/'):
            body_url = '/' + body_url
        body_url = instance_url + body_url
    
    logger.info(f"Downloading attachment from: {body_url}")
    
    # Download the file
    headers = {'Authorization': f'Bearer {sf.session_id}'}
    resp = sf.session.get(body_url, headers=headers, stream=True)
    resp.raise_for_status()
    
    return resp.content

def upload_attachment(sf, file_bytes, name, parent_id, content_type=None):
    """Upload attachment to target org."""
    payload = {
        "Name": name,
        "ParentId": parent_id,
        "Body": base64.b64encode(file_bytes).decode('utf-8')
    }
    
    if content_type:
        payload["ContentType"] = content_type
    
    # FIX: Use the proper Attachment.create() method
    result = sf.Attachment.create(payload)
    
    # FIX: Check result format - simple_salesforce returns dict with 'id' or 'success'
    if 'id' in result:
        return result['id']
    elif result.get('success'):
        return result['id']
    else:
        raise Exception(f"Upload failed: {result}")
    
    return result['id']

# =========================================
# RETRY WRAPPER
# =========================================

def retry(func):
    def wrapper(*args, **kwargs):
        last_exception = None
        for attempt in range(CONFIG["MAX_RETRIES"]):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                last_exception = e
                logger.warning(f"Attempt {attempt + 1} failed for {func.__name__}: {e}")
                if attempt == CONFIG["MAX_RETRIES"] - 1:
                    raise
                time.sleep(CONFIG["RETRY_DELAY"] * (2 ** attempt))
    return wrapper

# =========================================
# CORE PROCESSING
# =========================================

@retry
def process_row(row, sf_src, sf_tgt, prefix_map):
    """Process a single attachment migration."""
    
    logger.info(f"Processing attachment {row.SourceAttachmentId}")
    
    # Step 1: Resolve object type
    obj_type = resolve_object(prefix_map, row.SourceParentId)
    
    if obj_type not in VALID_PARENT_OBJECTS:
        raise Exception(f"Unsupported parent object: {obj_type}")
    
    if not row.TargetParentId:
        raise Exception("Missing TargetParentId")
    
    # Step 2: Fetch metadata
    meta = fetch_attachment_metadata(sf_src, row.SourceAttachmentId)
    
    # Step 3: Download binary (pass the full metadata dict)
    file_bytes = download_attachment(sf_src, meta)
    
    # Step 4: Upload to target
    new_id = upload_attachment(
        sf_tgt,
        file_bytes,
        meta["Name"],
        row.TargetParentId,
        meta.get("ContentType")
    )
    
    logger.info(f"Successfully migrated attachment {row.SourceAttachmentId} -> {new_id}")
    return new_id

# =========================================
# BATCH PROCESSOR
# =========================================

def process_batch():
    """Process one batch of attachments from the ledger."""
    conn = get_sql_conn()
    
    sf_src = connect_sf(SOURCE_CFG)
    sf_tgt = connect_sf(TARGET_CFG)
    
    prefix_map = build_prefix_map(sf_src)
    
    rows = fetch_batch(conn)
    
    if not rows:
        logger.info("No work remaining")
        return False
    
    ids = [str(r.Id) for r in rows]
    mark_in_progress(conn, ids)
    
    # Close connection before parallel processing to avoid connection issues
    conn.close()
    
    with ThreadPoolExecutor(max_workers=CONFIG["MAX_WORKERS"]) as executor:
        futures = {
            executor.submit(process_row, row, sf_src, sf_tgt, prefix_map): row
            for row in rows
        }
        
        # Reopen connection for updates
        update_conn = get_sql_conn()
        for future in as_completed(futures):
            row = futures[future]
            try:
                tgt_id = future.result()
                mark_success(update_conn, row.Id, tgt_id)
            except Exception as e:
                logger.error(f"Error for row {row.Id}: {e}")
                mark_failure(update_conn, row.Id, str(e))
        update_conn.close()
    
    return True

def migrate_attachment(sf_src, sf_tgt, attachment_id, target_parent_id):
    """Alternative method: migrate single attachment to ContentVersion."""
    
    # Step 1: Fetch metadata
    meta = sf_src.Attachment.get(attachment_id)
    
    # Step 2: Download binary
    # FIX: Handle the Body field properly
    body_url = meta.get('Body')
    if hasattr(body_url, 'rstrip'):
        body_url_str = body_url
    else:
        body_url_str = str(body_url)
    
    if not body_url_str.startswith('http'):
        instance_url = sf_src.instance_url.rstrip('/')
        if not body_url_str.startswith('/'):
            body_url_str = '/' + body_url_str
        body_url_str = instance_url + body_url_str
    
    headers = {'Authorization': f'Bearer {sf_src.session_id}'}
    resp = sf_src.session.get(body_url_str, headers=headers)
    resp.raise_for_status()
    file_bytes = resp.content
    
    # Step 3: Upload as ContentVersion
    payload = {
        "Title": meta["Name"],
        "PathOnClient": meta["Name"],
        "VersionData": base64.b64encode(file_bytes).decode('utf-8'),
        "FirstPublishLocationId": target_parent_id
    }
    
    # Use the proper simple_salesforce method
    result = sf_tgt.ContentVersion.create(payload)
    return result['id']

# =========================================
# MAIN LOOP
# =========================================

def run():
    logger.info("Starting attachment migration...")
    
    batch_count = 0
    while True:
        batch_count += 1
        logger.info(f"Processing batch {batch_count}")
        has_work = process_batch()
        if not has_work:
            break
        if CONFIG.get("throttle_seconds", 0) > 0:
            time.sleep(CONFIG["throttle_seconds"])
    
    logger.info("Attachment migration completed.")

# =========================================

if __name__ == "__main__":
    run()