provider "azurerm" {
  features {}
  subscription_id = "5e827c31-d475-4895-8ed2-032622fe7b61"
}

# Create resource group
resource "azurerm_resource_group" "billing" {
  name     = var.resource_group_name
  location = var.location
}

module "cosmos_db" {
  source                        = "./modules/cosmos_db"
  resource_group_name           = azurerm_resource_group.billing.name
  location                      = azurerm_resource_group.billing.location
  random_suffix                 = var.random_suffix
  existing_cosmosdb_name        = var.existing_cosmosdb_name
  existing_cosmosdb_resource_group = var.existing_cosmosdb_resource_group
  depends_on                    = [azurerm_resource_group.billing]
}

module "blob_storage" {
  source              = "./modules/blob_storage"
  resource_group_name = azurerm_resource_group.billing.name
  location            = azurerm_resource_group.billing.location
  random_suffix       = var.random_suffix
  depends_on          = [azurerm_resource_group.billing]
}

module "redis_cache" {
  source              = "./modules/redis_cache"
  resource_group_name = azurerm_resource_group.billing.name
  location            = azurerm_resource_group.billing.location
  random_suffix       = var.random_suffix
  depends_on          = [azurerm_resource_group.billing]
}

module "azure_functions" {
  source                    = "./modules/azure_functions"
  resource_group_name       = azurerm_resource_group.billing.name
  location                  = azurerm_resource_group.billing.location
  random_suffix             = var.random_suffix
  cosmos_db_endpoint        = module.cosmos_db.endpoint
  cosmos_db_key             = module.cosmos_db.primary_key
  storage_account_name      = module.blob_storage.storage_account_name
  storage_account_access_key = module.blob_storage.primary_access_key
  redis_hostname            = module.redis_cache.hostname
  redis_key                 = module.redis_cache.primary_access_key
  depends_on                = [azurerm_resource_group.billing, module.blob_storage, module.cosmos_db, module.redis_cache]
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.billing.name
  location            = azurerm_resource_group.billing.location
  random_suffix       = var.random_suffix
  function_app_id     = module.azure_functions.function_app_id
  depends_on          = [azurerm_resource_group.billing, module.azure_functions]
}
