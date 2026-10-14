# 1) Extract metadata (writes ledger.sqlite)
python migrate_unstructured.py extract --batch-id B001

# 2) Download binaries and compute SHA-256
python migrate_unstructured.py download --batch-id B001

# 3) Upload into target (ContentVersion)
python migrate_unstructured.py upload --batch-id B001 --parent-map parent_id_map.csv

# 4) Link to target records (ContentDocumentLink)
python migrate_unstructured.py link --batch-id B001 --parent-map parent_id_map.csv

# 5) Validate counts and byte totals
python migrate_unstructured.py validate --batch-id B001

# Extract metadata into MSSQL ledger
python migrate_unstructured_mssql.py extract --batch-id B001

# Download binaries + SHA-256 hashes
python migrate_unstructured_mssql.py download --batch-id B001

# Upload to target (ContentVersion, base64 small / multipart large) [5](https://teams.microsoft.com/l/meeting/details?eventId=AAMkAGY3ZTAzMmYwLWZkZDQtNGViZi04NDZiLTY1ZDhkY2NmNDY3YgFRAAgI3rFLvejAAEYAAAAAVN5N3TwlJE69q-kp-ovd_wcAlOJvO59WGUC6siMYOXSdqwAAAAABDQAAlOJvO59WGUC6siMYOXSdqwAAaaYK5AAAEA%3d%3d)[6](https://teams.microsoft.com/l/meeting/details?eventId=AAMkAGY3ZTAzMmYwLWZkZDQtNGViZi04NDZiLTY1ZDhkY2NmNDY3YgFRAAgI3qS5F0zAAEYAAAAAVN5N3TwlJE69q-kp-ovd_wcAlOJvO59WGUC6siMYOXSdqwAAAAABDQAAlOJvO59WGUC6siMYOXSdqwAAaaYK5AAAEA%3d%3d)
python migrate_unstructured_mssql.py upload --batch-id B001 --parent-map parent_id_map.csv

# Link to target parents (ContentDocumentLink)
python migrate_unstructured_mssql.py link --batch-id B001 --parent-map parent_id_map.csv

# Produce reconciliation report
python migrate_unstructured_mssql.py validate --batch-id B001