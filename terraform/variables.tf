variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for resource names"
  type        = string
}

variable "cosmos_db_endpoint" {
  description = "Cosmos DB account endpoint"
  type        = string
}

variable "cosmos_db_key" {
  description = "Cosmos DB primary key"
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "storage_account_access_key" {
  description = "Primary access key for the storage account"
  type        = string
  sensitive   = true
}

variable "redis_hostname" {
  description = "Hostname for the Azure Redis Cache"
  type        = string
}

variable "redis_key" {
  description = "Primary access key for the Azure Redis Cache"
  type        = string
  sensitive   = true
}

variable "function_app_id" {
  description = "ID of the billing API Function App"
  type        = string
}
