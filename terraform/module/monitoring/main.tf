resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "billing-workspace"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "app_insights" {
  name                = "billing-appinsights"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "alert_group" {
  name                = "billing-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "billalerts"
  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"
  }
}

resource "azurerm_monitor_metric_alert" "redis_miss" {
  name                = "redis-miss-rate-alert"
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