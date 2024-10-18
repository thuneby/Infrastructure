locals {
  storage-rg-name     = "storage"
  cosmos_account_name = "infrastructure"
  cosmos_db_name      = "infrastructure"
  cosmos_free_tier    = true
}


resource "azurecaf_name" "rg-storage" {
  name          = local.storage-rg-name
  resource_type = "azurerm_resource_group"
}

resource "azurerm_resource_group" "rg_storage" {
  name     = azurecaf_name.rg-storage.result
  location = var.location
}

resource "azurecaf_name" "infrastructure_file_storage" {
  name          = "infrastructurefiles"
  resource_type = "azurerm_storage_account"
  #   suffixes      = [var.env]
  clean_input   = true
  random_length = 5
}

resource "azurerm_storage_account" "integration_functions" {
  name                     = azurecaf_name.infrastructure_file_storage.result
  resource_group_name      = azurerm_resource_group.rg_storage.name
  location                 = azurerm_resource_group.rg_storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurecaf_name" "cosmos_account_name" {
  name          = local.cosmos_account_name
  resource_type = "azurerm_cosmosdb_account"
  clean_input   = true
  random_length = 5
}

resource "azurerm_cosmosdb_account" "infrastructure" {
  name                = azurecaf_name.cosmos_account_name.result
  resource_group_name = azurerm_resource_group.rg_storage.name
  location            = azurerm_resource_group.rg_storage.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  free_tier_enabled   = local.cosmos_free_tier

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.rg_storage.location
    failover_priority = 0
  }

  capacity {
    total_throughput_limit = 1000
  }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = local.cosmos_db_name
  resource_group_name = azurerm_resource_group.rg_storage.name
  account_name        = azurerm_cosmosdb_account.infrastructure.name
  throughput          = var.cosmos_troughput
}

resource "azurerm_key_vault_secret" "cosmos_connection_string" {
  name         = "cosmos-connection-string"
  value        = azurerm_cosmosdb_account.infrastructure.primary_sql_connection_string
  key_vault_id = azurerm_key_vault.infrastructure_keyvault.id
  depends_on = [
    azurerm_key_vault.infrastructure_keyvault,
    azurerm_cosmosdb_account.infrastructure
  ]
}