resource "azurecaf_name" "apim_name" {
  name          = "infrastructure-apim"
  resource_type = "azurerm_api_management"
  clean_input   = true
}

resource "azurerm_api_management" "infrastructure" {
  name                = azurecaf_name.apim_name.result
  location            = azurerm_resource_group.rg_shared_services.location
  resource_group_name = azurerm_resource_group.rg_shared_services.name
  publisher_name      = "Sharperbox"
  publisher_email     = "info@sharperbox.dk"

  sku_name = "Consumption_0"

  identity {
    type = "SystemAssigned"
  }
}