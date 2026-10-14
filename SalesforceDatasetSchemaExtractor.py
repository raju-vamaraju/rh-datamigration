import json
import requests

# Simulated environment configurations inside a Python Class
API_VERSION = "v61.0"


class SalesforceDatasetSchemaExtractor:

    def __init__(self, instance_url, access_token):
        self.instance_url = instance_url
        self.access_token = access_token
        self.headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
        }

    def extract_schema(self, dataset_id):
        # 1. Hit the base dataset endpoint requested by your string format
        dataset_url = f"{self.instance_url}/services/data/{API_VERSION}/wave/datasets/{dataset_id}"

        print(f"Fetching dataset configurations from: {dataset_url}")
        dataset_response = requests.get(dataset_url, headers=self.headers)
        dataset_response.raise_for_status()
        dataset_data = dataset_response.json()

        # 2. Extract the current structural version ID of the dataset
        current_version_id = dataset_data.get("currentVersionId")
        if not current_version_id:
            print("Error: Could not retrieve the current version ID.")
            return None

        # 3. Construct the version endpoint to expose the XMD schema layout
        version_url = f"{dataset_url}/versions/{current_version_id}"

        print(f"Fetching schema payload from version endpoint: {version_url}")
        version_response = requests.get(version_url, headers=self.headers)
        version_response.raise_for_status()
        version_data = version_response.json()

        # 4. Extract schema elements located in the User XMD and Main XMD sections
        schema_metadata = {
            "dataset_id": dataset_id,
            "version_id": current_version_id,
            "dimensions": version_data.get("xmdMain", {}).get("dimensions", []),
            "measures": version_data.get("xmdMain", {}).get("measures", []),
            "dates": version_data.get("xmdMain", {}).get("dates", []),
        }

        return schema_metadata


# --- Script Execution Example ---
if __name__ == "__main__":
    # Insert active credentials
    INSTANCE_URL = "https://ioofadviserhub--hubuat.sandbox.lightning.force.com"
    ACCESS_TOKEN = "mlMvNgFbW6UiniZoBLt4M42zp"
    DATASET_ID = "0FbMq00000105ojKAA"  # 18-character Salesforce Asset ID

    extractor = SalesforceDatasetSchemaExtractor(INSTANCE_URL, ACCESS_TOKEN)
    try:
        extracted_schema = extractor.extract_schema(DATASET_ID)

        if extracted_schema:
            # Save schema array out cleanly as a readable JSON layout
            output_file = f"./metadata/datasets/schema_{DATASET_ID}.json"
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(extracted_schema, f, indent=4)
            print(f"Success! Schema mapped and written directly to {output_file}")

    except requests.exceptions.HTTPError as err:
        print(f"API Error Encountered: {err}")