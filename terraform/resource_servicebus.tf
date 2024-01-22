resource "azurecaf_name" "servicebus_name" {
  name          = "infrastructure"
  resource_type = "azurerm_servicebus_namespace"
  clean_input   = true
}

resource "azurerm_servicebus_namespace" "infrastructure" {
  name                = azurecaf_name.servicebus_name.result
  resource_group_name = azurerm_resource_group.rg_shared_services.name
  location            = azurerm_resource_group.rg_shared_services.location
  sku                 = "Basic"
  capacity            = 0

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}