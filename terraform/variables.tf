# Defining variables for the Azure serverless cost optimization solution
variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "billing-rg"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"
}

variable "random_suffix" {
  description = "Random suffix for resource names"
  type        = string
  default     = "123"
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
