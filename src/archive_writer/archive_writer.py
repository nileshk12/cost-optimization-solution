import azure.functions as func
from azure.cosmos import CosmosClient
from azure.storage.blob import BlobServiceClient
from datetime import datetime, timedelta
import json

def main(timer: func.TimerRequest) -> None:
    cosmos_client = CosmosClient('COSMOS_ENDPOINT', 'COSMOS_KEY')
    blob_service = BlobServiceClient.from_connection_string('STORAGE_CONNECTION')

    database = cosmos_client.get_database_client('billing')
    container = database.get_container_client('records')
    three_months_ago = datetime.utcnow() - timedelta(days=90)

    # Query records older than 3 months
    query = f"SELECT * FROM c WHERE c._ts < '{three_months_ago.isoformat()}'"
    for item in container.query_items(query, enable_cross_partition_query=True):
        blob_client = blob_service.get_blob_client(container='billing-archive', blob=f"{item['id']}.json")
        blob_client.upload_blob(json.dumps(item), overwrite=True)
        blob_client.set_standard_blob_tier("Archive")
        container.delete_item(item=item['id'], partition_key=item['id'])