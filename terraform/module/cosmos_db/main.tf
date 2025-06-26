resource "azurerm_cosmosdb_account" "db" {
  name                = "billing-cosmosdb"
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  enable_free_tier    = true
  geo_location {
    location          = var.location
    failover_priority = 0
  }
  consistency_policy {
    consistency_level = "Session"
  }
}

output "endpoint" {
  value = azurerm_cosmosdb_account.db.endpoint
}

output "primary_key" {
  value = azurerm_cosmosdb_account.db.primary_master_key
  sensitive = true
}