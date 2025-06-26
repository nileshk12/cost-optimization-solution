resource "azurerm_function_app" "billing_api" {
  name                       = "billing-api"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = var.storage_account
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  app_settings = {
    "CosmosDB_Endpoint" = var.cosmos_db_endpoint
    "CosmosDB_Key"      = var.cosmos_db_key
    "Redis_Host"        = var.redis_host
    "Redis_Key"         = var.redis_key
  }
}

resource "azurerm_function_app" "archive_job" {
  name                       = "archive-job"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = var.storage_account
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  app_settings = {
    "CosmosDB_Endpoint" = var.cosmos_db_endpoint
    "CosmosDB_Key"      = var.cosmos_db_key
    "Storage_Account"   = var.storage_account
  }
}

resource "azurerm_app_service_plan" "plan" {
  name                = "billing-functions-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

output "function_app_id" {
  value = azurerm_function_app.billing_api.id
}