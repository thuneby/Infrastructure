locals {
  analytics_name = "platform"
}

resource "azurecaf_name" "rg-analytics-name" {
  name          = "analytics"
  resource_type = "azurerm_resource_group"
}

resource "azurerm_resource_group" "analytics" {
  name     = azurecaf_name.rg-analytics-name.result
  location = var.location
}

resource "azurerm_log_analytics_workspace" "analytics" {
  name                = local.analytics_name
  location            = var.location
  resource_group_name = azurerm_resource_group.analytics.name
  sku                 = var.analytics_sku
  retention_in_days   = 30
}