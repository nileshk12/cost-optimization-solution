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

resource "azurerm_storage_account" "billing" {
  name                     = "billingarchive${var.random_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
}

resource "azurerm_storage_container" "archive" {
  name                  = "billing-archive"
  storage_account_name  = azurerm_storage_account.billing.name
  container_access_type = "private"
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.billing.name
}

output "primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.billing.primary_access_key
  sensitive   = true
}





