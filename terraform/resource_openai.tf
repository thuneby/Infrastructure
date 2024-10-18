locals {
  rg-name         = "openai"
  deployment-name = "chatmodel"
  resource-name   = "infrastructure"
}

resource "azurecaf_name" "rg-openai" {
  name          = local.rg-name
  resource_type = "azurerm_resource_group"
}

resource "azurerm_resource_group" "openai" {
  name     = azurecaf_name.rg-openai.result
  location = var.openai_location
}

resource "azurecaf_name" "cognitive_account" {
  name          = local.resource-name
  resource_type = "azurerm_cognitive_account"
  clean_input   = true
  # suffixes      = [var.env]
}

resource "azurerm_cognitive_account" "openai" {
  name                = azurecaf_name.cognitive_account.result
  location            = azurerm_resource_group.openai.location
  resource_group_name = azurerm_resource_group.openai.name
  kind                = "OpenAI"
  sku_name            = "S0"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_resource_group.openai
  ]
}

resource "azurerm_cognitive_deployment" "chatmodel" {
  name                 = local.deployment-name
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }

  sku {
    name = "Standard"
  }

  depends_on = [
    azurerm_cognitive_account.openai
  ]
}