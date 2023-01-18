
data "azurerm_api_management" "apim_instance" {
  name                = var.apim_name
  resource_group_name = var.apim_rg
}

resource "azurerm_log_analytics_workspace" "main_law" {
  name                = "apim-multi-tenancy-law"
  location            = data.azurerm_api_management.apim_instance.location
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "reference_data_table_storage" {
  source                                  = "../modules/table-storage/"
  storage_account_name                    = var.reference_data_storage_account_name
  resource_group_name                     = data.azurerm_api_management.apim_instance.resource_group_name
  location                                = data.azurerm_api_management.apim_instance.location
  azurerm_eventgrid_subscription_name     = "${var.apim_name}-eventgrid-subscription"
  subscription_scope_id                   = data.azurerm_api_management.apim_instance.id
  connections_azuretables_name            = "AzureTablesConnection"
  default_admin_email                     = var.admin_email_address
}

//logic app action group
module "logic_app_action_group" {
  depends_on = [
    module.reference_data_table_storage
  ]
  source              = "../modules/action-group/"
  email_address       = var.admin_email_address
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  connections_azuretables_name = "AzureTablesConnection"
  apim_instance_name = data.azurerm_api_management.apim_instance.name
}

module "multi_app_insights_query_alert" {
  source                     = "../modules/multi-resource-alert/"
  alert_rule_name            = "ALL_SUB-APP-INSIGHTS-QUERY-ALERTS"
  alert_rule_query           = <<-QUERY
                                  AppRequests
                                  | where AppRoleName contains "${data.azurerm_api_management.apim_instance.name}" and ResultCode !in (200,201)
                                  | project ApiName = tostring(split(OperationName, ";")[0]), OperationName, DurationMs, ResultCode, AppRoleName, _ResourceId
                                QUERY
  dimension_name             = "Occurence"
  location                   = data.azurerm_api_management.apim_instance.location
  resource_group_name        = data.azurerm_api_management.apim_instance.resource_group_name
  app_insights_scope         = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  logic_apps_action_group_id = module.logic_app_action_group.action_group.id
}
