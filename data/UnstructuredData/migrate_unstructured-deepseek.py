import base64
from simple_salesforce import Salesforce
import requests

# ========== CONFIGURATION ==========
# Source org
SOURCE_USER = 'user@source.com'
SOURCE_PASS = 'password'
SOURCE_TOKEN = 'security_token'  # or None if no token

# Target org
TARGET_USER = 'user@target.com'
TARGET_PASS = 'password'
TARGET_TOKEN = 'security_token'

# Optional: map external IDs (source parent ID -> target parent ID)
# You would build this mapping from your record migration step.
PARENT_ID_MAP = {
    '001XXXXXXXXXXXXXXX': '001YYYYYYYYYYYYYYY',  # Source Account ID -> Target Account ID
    # add more as needed
}
# ===================================

def migrate_content_versions(batch_size=10):
    """Extract ContentVersion from source and upload to target."""
    
    # 1. Connect to both orgs
    sf_source = Salesforce(
        username=SOURCE_USER,
        password=SOURCE_PASS,
        security_token=SOURCE_TOKEN
    )
    sf_target = Salesforce(
        username=TARGET_USER,
        password=TARGET_PASS,
        security_token=TARGET_TOKEN
    )
    
    # 2. Query latest version of each file from source
    #    (adjust fields as needed – include parent relationship info)
    query = """
        SELECT Id, Title, PathOnClient, FileExtension,
               ContentDocumentId, VersionData, IsLatest,
               FirstPublishLocationId
        FROM ContentVersion
        WHERE IsLatest = true
        LIMIT 100
    """
    
    results = sf_source.query_all(query)
    records = results['records']
    print(f"Found {len(records)} files to migrate")
    
    for idx, cv in enumerate(records):
        source_file_id = cv['Id']
        title = cv['Title']
        ext = cv.get('FileExtension', '')
        parent_source_id = cv.get('FirstPublishLocationId')
        
        # 3. Resolve parent ID in target org
        if parent_source_id not in PARENT_ID_MAP:
            print(f"Skipping {title} – no parent mapping for {parent_source_id}")
            continue
        target_parent_id = PARENT_ID_MAP[parent_source_id]
        
        # 4. Download binary data from source
        #    VersionData is a URL; we must fetch it separately
        version_data_url = cv['VersionData']
        auth_header = {'Authorization': f'Bearer {sf_source.session_id}'}
        resp = requests.get(version_data_url, headers=auth_header, stream=True)
        
        if resp.status_code != 200:
            print(f"Failed to download {title}: {resp.status_code}")
            continue
        
        binary_content = resp.content
        # Encode to base64 string for upload
        version_data_b64 = base64.b64encode(binary_content).decode('utf-8')
        
        # 5. Create ContentVersion in target org
        new_cv = {
            'Title': title,
            'PathOnClient': title,  # required
            'FirstPublishLocationId': target_parent_id,
            'VersionData': version_data_b64,
            'ContentLocation': 'S'  # 'S' for Salesforce
        }
        
        # Optional: set file extension correctly
        if ext:
            new_cv['FileExtension'] = ext
        
        try:
            result = sf_target.ContentVersion.create(new_cv)
            print(f"✅ Migrated {title} -> {result['id']}")
        except Exception as e:
            print(f"❌ Failed to upload {title}: {e}")
        
        # Batch progress & API limit awareness
        if (idx + 1) % batch_size == 0:
            print(f"Processed {idx+1} files...")
    
    print("Migration complete.")

if __name__ == '__main__':
    migrate_content_versions()