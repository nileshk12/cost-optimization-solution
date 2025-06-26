import azure.functions as func
from azure.cosmos import CosmosClient
from redis import Redis
from azure.storage.blob import BlobServiceClient
import json

def main(req: func.HttpRequest) -> func.HttpResponse:
    record_id = req.params.get('id')
    api_version = req.headers.get('X-API-Version', '1.0')

    redis_client = Redis(host='REDIS_HOST', password='REDIS_KEY')
    cosmos_client = CosmosClient('COSMOS_ENDPOINT', 'COSMOS_KEY')
    blob_service = BlobServiceClient.from_connection_string('STORAGE_CONNECTION')

    # Try Redis cache first
    cached_record = redis_client.get(f"billing:{record_id}")
    if cached_record:
        return func.HttpResponse(json.dumps(json.loads(cached_record)), status_code=200)

    # Fallback to Cosmos DB
    database = cosmos_client.get_database_client('billing')
    container = database.get_container_client('records')
    try:
        record = container.read_item(item=record_id, partition_key=record_id)
        redis_client.setex(f"billing:{record_id}", 3600, json.dumps(record))  # Cache for 1 hour
        return func.HttpResponse(json.dumps(record), status_code=200)
    except:
        pass

    # Fallback to Blob Storage (Archive Tier)
    blob_client = blob_service.get_blob_client(container='billing-archive', blob=f"{record_id}.json")
    if blob_client.exists():
        record = json.loads(blob_client.download_blob().readall())
        redis_client.setex(f"billing:{record_id}", 3600, json.dumps(record))  # Cache for 1 hour
        # Trigger rehydration if accessed frequently
        access_count = redis_client.incr(f"access:{record_id}")
        if access_count > 5:  # Rehydrate after 5 accesses
            container.upsert_item(record)
            redis_client.delete(f"access:{record_id}")
        return func.HttpResponse(json.dumps(record), status_code=200)

    return func.HttpResponse("Record not found", status_code=404)