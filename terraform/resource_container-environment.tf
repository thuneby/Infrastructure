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
  name                       = azurecaf_name.environment.result
  location                   = var.location
  resource_group_name        = azurerm_resource_group.applications.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.analytics.id

  workload_profile {
    name                  = "internal"
    workload_profile_type = "E4"
    maximum_count         = 5
    minimum_count         = 0
  }

  depends_on = [
    azurerm_log_analytics_workspace.analytics
  ]
}

resource "azurerm_user_assigned_identity" "dapr" {
  location            = var.location
  name                = "id-dapr"
  resource_group_name = azurerm_resource_group.applications.name
}

resource "azurerm_role_assignment" "key_vault_access_dapr" {
  role_definition_name = "Key Vault User"
  scope                = azurerm_key_vault.infrastructure_keyvault.id
  principal_id         = azurerm_user_assigned_identity.dapr.principal_id

  depends_on = [
    azurerm_key_vault.infrastructure_keyvault,
    azurerm_user_assigned_identity.dapr
  ]
}


resource "azurerm_container_app_environment_dapr_component" "secret-store" {
  name                         = "secret-store"
  container_app_environment_id = azurerm_container_app_environment.integrations.id
  component_type               = "secretstores.azure.keyvault"
  version                      = "v1"
  metadata {
    name  = "vaultName"
    value = azurerm_key_vault.infrastructure_keyvault.name
  }
  metadata {
    name  = "azureClientId"
    value = azurerm_user_assigned_identity.dapr.client_id
  }

  depends_on = [
    azurerm_container_app_environment.integrations,
    azurerm_key_vault.infrastructure_keyvault,
    azurerm_role_assignment.key_vault_access_dapr
  ]
}