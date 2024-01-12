resource "azurecaf_name" "resource-group" {
  name          = "container-apps"
  resource_type = "azurerm_resource_group"
}


resource "azurerm_resource_group" "applications" {
  name     = azurecaf_name.resource-group.result
  location = var.location
}

resource "azurecaf_name" "environment" {
  name          = "applications"
  resource_type = "azurerm_container_app_environment"
  clean_input   = true
  # suffixes      = [var.env]
}

resource "azurerm_container_app_environment" "integrations" {
  name                           = azurecaf_name.environment.result
  location                       = var.location
  resource_group_name            = azurerm_resource_group.applications.name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.log_analytics_workspace.id
  internal_load_balancer_enabled = false

  workload_profile {
    name                  = "internal"
    workload_profile_type = "E4"
    maximum_count         = 5
    minimum_count         = 0
  }

  depends_on = [
    azurerm_subnet.container
  ]
}