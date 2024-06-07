terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.107.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "stplatformterraform"
    container_name       = "tfstatefile-infrastructure"
    key                  = "infrastructure"
  }
}
provider "azurerm" {
  features {}
}