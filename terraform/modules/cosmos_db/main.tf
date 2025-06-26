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

variable "existing_cosmosdb_name" {
  description = "Name of existing Cosmos DB account (optional)"
  type        = string
  default     = ""
}

variable "existing_cosmosdb_resource_group" {
  description = "Resource group of existing Cosmos DB account (optional)"
  type        = string
  default     = ""
}

# Use existing Cosmos DB if specified
data "azurerm_cosmosdb_account" "existing" {
  count               = var.existing_cosmosdb_name != "" ? 1 : 0
  name                = var.existing_cosmosdb_name
  resource_group_name = var.existing_cosmosdb_resource_group
}

# Create new Cosmos DB if no existing instance is specified
resource "azurerm_cosmosdb_account" "billing" {
  count               = var.existing_cosmosdb_name == "" ? 1 : 0
  name                = "billing-cosmos-${var.random_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "billing" {
  name                = "billing"
  resource_group_name = var.resource_group_name
  account_name        = var.existing_cosmosdb_name != "" ? data.azurerm_cosmosdb_account.existing[0].name : azurerm_cosmosdb_account.billing[0].name
}

resource "azurerm_cosmosdb_sql_container" "records" {
  name                = "records"
  resource_group_name = var.resource_group_name
  account_name        = var.existing_cosmosdb_name != "" ? data.azurerm_cosmosdb_account.existing[0].name : azurerm_cosmosdb_account.billing[0].name
  database_name       = azurerm_cosmosdb_sql_database.billing.name
  partition_key_paths = ["/id"]
  throughput		= 400
}

output "endpoint" {
  description = "Cosmos DB account endpoint"
  value       = var.existing_cosmosdb_name != "" ? data.azurerm_cosmosdb_account.existing[0].endpoint : azurerm_cosmosdb_account.billing[0].endpoint
}

output "primary_key" {
  description = "Cosmos DB primary key"
  value       = var.existing_cosmosdb_name != "" ? data.azurerm_cosmosdb_account.existing[0].primary_key : azurerm_cosmosdb_account.billing[0].primary_key
  sensitive   = true
}
