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

resource "azurerm_app_service_plan" "billing" {
  name                = "billing-functions-plan-${var.random_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "billing_api" {
  name                       = "billing-api-${var.random_suffix}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.billing.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  app_settings = {
    "CosmosDB_Endpoint" = var.cosmos_db_endpoint
    "CosmosDB_Key"      = var.cosmos_db_key
    "Redis_Host"        = var.redis_hostname
    "Redis_Key"         = var.redis_key
  }
}

resource "azurerm_function_app" "archive_job" {
  name                       = "archive-job-${var.random_suffix}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.billing.id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key
  app_settings = {
    "CosmosDB_Endpoint" = var.cosmos_db_endpoint
    "CosmosDB_Key"      = var.cosmos_db_key
    "Storage_Account"   = var.storage_account_name
  }
}

output "function_app_id" {
  description = "ID of the billing API Function App"
  value       = azurerm_function_app.billing_api.id
}
