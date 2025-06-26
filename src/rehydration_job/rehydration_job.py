import azure.functions as func
from azure.cosmos import CosmosClient
from azure.storage.blob import BlobServiceClient
from redis import Redis
import json

def main(timer: func.TimerRequest) -> None:
    redis_client = Redis(host='REDIS_HOST', password='REDIS_KEY')
    cosmos_client = CosmosClient('COSMOS_ENDPOINT', 'COSMOS_KEY')
    blob_service = BlobServiceClient.from_connection_string('STORAGE_CONNECTION')

    database = cosmos_client.get_database_client('billing')
    container = database.get_container_client('records')

    # Check Redis for frequently accessed archived records
    for key in redis_client.scan_iter("access:*"):
        record_id = key.split(":")[1]
        access_count = redis_client.get(key)
        if int(access_count) > 5:
            blob_client = blob_service.get_blob_client(container='billing-archive', blob=f"{record_id}.json")
            if blob_client.exists():
                blob_client.set_standard_blob_tier("Hot")  # Rehydrate to Hot tier
                record = json.loads(blob_client.download_blob().readall())
                container.upsert_item(record)
                redis_client.delete(key)