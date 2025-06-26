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

resource "azurerm_redis_cache" "billing" {
  name                = "billing-redis-${var.random_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
}

output "hostname" {
  description = "Hostname for the Redis Cache"
  value       = azurerm_redis_cache.billing.hostname
}

output "primary_access_key" {
  description = "Primary access key for the Redis Cache"
  value       = azurerm_redis_cache.billing.primary_access_key
  sensitive   = true
}
