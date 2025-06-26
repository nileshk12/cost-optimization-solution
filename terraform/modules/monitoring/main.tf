locals {
  safe_suffix = length(var.random_suffix) > 0 ? replace(trim(var.random_suffix, "-"), "/[^a-zA-Z0-9-]/", "") : "default"
}

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

variable "function_app_id" {
  description = "ID of the billing API Function App"
  type        = string
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "billing-workspace-${local.safe_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "app_insights" {
  name                = "billing-appinsights-${local.safe_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "alert_group" {
  name                = "billing-alerts-${local.safe_suffix}"
  resource_group_name = var.resource_group_name
  short_name          = "billalerts"
  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"
  }
}

resource "azurerm_monitor_metric_alert" "redis_miss" {
  name                = "redis-miss-rate-alert-${local.safe_suffix}"
  resource_group_name = var.resource_group_name
  scopes              = [var.function_app_id]
  description         = "Alert when Redis cache miss rate exceeds 80%"
  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HttpResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0.8
  }
  action {
    action_group_id = azurerm_monitor_action_group.alert_group.id
  }
}
