# Defining variables for the Azure serverless cost optimization solution
variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "billing-rg"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"
}

variable "cosmos_db_endpoint" {
  description = "Endpoint for the Cosmos DB account"
  type        = string
  sensitive   = true
}

variable "cosmos_db_key" {
  description = "Primary key for the Cosmos DB account"
  type        = string
  sensitive   = true
}

variable "storage_account" {
  description = "Name of the Azure storage account"
  type        = string
}

variable "redis_host" {
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