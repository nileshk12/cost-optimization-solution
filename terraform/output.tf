output "cosmos_db_endpoint" {
  description = "Endpoint for the Cosmos DB account"
  value       = module.cosmos_db.endpoint
}

output "cosmos_db_key" {
  description = "Primary key for the Cosmos DB account"
  value       = module.cosmos_db.primary_key
  sensitive   = true
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.blob_storage.storage_account_name
}

output "storage_account_access_key" {
  description = "Primary access key for the storage account"
  value       = module.blob_storage.primary_access_key
  sensitive   = true
}

output "redis_hostname" {
  description = "Hostname for the Redis Cache"
  value       = module.redis_cache.hostname
}

output "redis_key" {
  description = "Primary access key for the Redis Cache"
  value       = module.redis_cache.primary_access_key
  sensitive   = true
}

output "function_app_id" {
  description = "ID of the billing API Function App"
  value       = module.azure_functions.function_app_id
}
