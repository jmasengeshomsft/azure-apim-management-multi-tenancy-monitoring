resource "azurerm_storage_account" "account" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  account_kind                    = "StorageV2"

  identity {
    type  = "SystemAssigned"
  }

  network_rules {
    default_action             = "Allow"
  }

  tags = var.tags
}

resource "azurerm_storage_table" "table_storage" {
  name                 = "ApimAlertsReferenceData01"
  storage_account_name = azurerm_storage_account.account.name
}