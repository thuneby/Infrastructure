resource "azurecaf_name" "rg_shared_services_name" {
  name          = "shared-services"
  resource_type = "azurerm_resource_group"
  clean_input   = true
}

resource "azurerm_resource_group" "rg_shared_services" {
  name     = azurecaf_name.rg_shared_services_name.result
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurecaf_name" "key_vault_name" {
  name          = "infrastructure"
  resource_type = "azurerm_key_vault"
  clean_input   = true
  random_length = 5
}

resource "azurerm_key_vault" "infrastructure_keyvault" {
  name                        = azurecaf_name.key_vault_name.result
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  resource_group_name         = azurerm_resource_group.rg_shared_services.name
  location                    = azurerm_resource_group.rg_shared_services.location
  enabled_for_disk_encryption = true
  sku_name                    = "standard"

  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurecaf_name" "container_registry_name" {
  name          = "thuneby-infrastructure"
  resource_type = "azurerm_container_registry"
  clean_input   = true
}

resource "azurerm_container_registry" "infrastructure_container_registry" {
  name                = azurecaf_name.container_registry_name.result
  resource_group_name = azurerm_resource_group.rg_shared_services.name
  location            = azurerm_resource_group.rg_shared_services.location
  sku                 = "Basic"
  admin_enabled       = true

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}