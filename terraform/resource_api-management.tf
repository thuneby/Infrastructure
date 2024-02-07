locals {
  apim_name       = "infrastructure"
  publisher_name  = "Sharperbox"
  publisher_email = "info@sharperbox.dk"
}

resource "azurecaf_name" "apim_name" {
  name          = local.apim_name
  resource_type = "azurerm_api_management"
  clean_input   = true
}

resource "azurerm_api_management" "infrastructure" {
  name                = azurecaf_name.apim_name.result
  location            = azurerm_resource_group.rg_shared_services.location
  resource_group_name = azurerm_resource_group.rg_shared_services.name
  publisher_name      = local.publisher_name
  publisher_email     = local.publisher_email

  sku_name = var.apim_sku

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "apim_service_contributor" {
  scope                = azurerm_app_configuration.infrastructure.id
  role_definition_name = "API Management Service Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}