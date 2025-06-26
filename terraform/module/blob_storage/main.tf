resource "azurerm_storage_account" "storage" {
  name                     = "billingarchive${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
}

resource "azurerm_storage_container" "archive" {
  name                  = "billing-archive"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}