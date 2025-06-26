provider "azurerm" {
  features {}
}

# Create resource group if it doesn't exist
resource "azurerm_resource_group" "billing_rg" {
  name     = var.resource_group_name
  location = var.location
}

module "cosmos_db" {
  source              = "./modules/cosmos_db"
  resource_group_name = azurerm_resource_group.billing_rg.name
  location            = azurerm_resource_group.billing_rg.location
  depends_on          = [azurerm_resource_group.billing_rg]
}

module "blob_storage" {
  source              = "./modules/blob_storage"
  resource_group_name = azurerm_resource_group.billing_rg.name
  location            = azurerm_resource_group.billing_rg.location
  depends_on          = [azurerm_resource_group.billing_rg]
}

module "redis_cache" {
  source              = "./modules/redis_cache"
  resource_group_name = azurerm_resource_group.billing_rg.name
  location            = azurerm_resource_group.billing_rg.location
  depends_on          = [azurerm_resource_group.billing_rg]
}

module "azure_functions" {
  source                     = "./modules/azure_functions"
  resource_group_name        = azurerm_resource_group.billing_rg.name
  location                   = azurerm_resource_group.billing_rg.location
  cosmos_db_endpoint         = module.cosmos_db.endpoint
  cosmos_db_key              = module.cosmos_db.primary_key
  storage_account            = module.blob_storage.storage_account_name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  redis_host                 = module.redis_cache.hostname
  redis_key                  = module.redis_cache.primary_access_key
  depends_on                 = [azurerm_resource_group.billing_rg, module.blob_storage]
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.billing_rg.name
  location            = azurerm_resource_group.billing_rg.location
  function_app_id     = module.azure_functions.function_app_id
  depends_on          = [azurerm_resource_group.billing_rg, module.azure_functions]
}

# Reference storage account for access key
resource "azurerm_storage_account" "storage" {
  name                     = "billingarchive${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.billing_rg.name
  location                 = azurerm_resource_group.billing_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}