resource "azurerm_redis_cache" "redis" {
  name                = "billing-redis"
  resource_group_name = var.resource_group_name
  location            = var.location
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
}

output "hostname" {
  value = azurerm_redis_cache.redis.hostname
}

output "primary_access_key" {
  value = azurerm_redis_cache.redis.primary_access_key
  sensitive = true
}