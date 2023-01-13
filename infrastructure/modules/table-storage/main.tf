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

resource "azurerm_resource_group_template_deployment" "ref_data_logic_app" {
  depends_on = [
    azurerm_storage_account.account
  ]
  name                     = "ref-data-logic-app"
  resource_group_name      = var.resource_group_name
  deployment_mode          = "Incremental"
  template_content         = file("${path.module}/arm-templates/create-reference-data-logic-app.json")
  parameters_content       = jsonencode({
    "connections_azuretables_name" = {
      value = var.connections_azuretables_name
    },
    "default_admin_email" = {
      value = var.default_admin_email
    }
  })
}

resource "azurerm_eventgrid_event_subscription" "subscription" {
  name  = var.azurerm_eventgrid_subscription_name
  scope = var.subscription_scope_id

  webhook_endpoint {
    url = jsondecode(azurerm_resource_group_template_deployment.ref_data_logic_app.output_content).logicAppsCallBackUrl.value
  }

  included_event_types = [
     "Microsoft.ApiManagement.APICreated",
  ]
}
