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
