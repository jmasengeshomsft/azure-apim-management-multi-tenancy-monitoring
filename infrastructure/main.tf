
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

//logic app action group
module "logic_app_action_group" {
  source              = "./modules/action-group/"
  email_address       = var.admin_email_address
  location            = data.azurerm_api_management.apim_instance.location
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
}

//tenant or team A
resource "azurerm_resource_group" "tenant_a_rg" {
  name     = var.tenant_a_rg
  location = var.tenant_a_rg_location
}

module "tenant_a" {
  source                      = "./modules/tenant/"
  tenant_name                 = "tenant-a"
  product_name                = "tenant-a-product"
  group_name                  = "tenant-a-group"
  apim_name                   = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name    = data.azurerm_api_management.apim_instance.resource_group_name
  law_workspace_id            = azurerm_log_analytics_workspace.main_law.id
  tenant_default_principal_id = var.tenant_a_default_principal_id
  tenant_resource_group_name  = azurerm_resource_group.tenant_a_rg.name
  tenant_location             = azurerm_resource_group.tenant_a_rg.location
}

//Conference API
module "team_a_api" {
  source                           = "./modules/tenant-api/"
  api_name                         = "team-a-conference-api-1"
  api_service_url                  = "https://conferenceapi.azurewebsites.net"
  api_path                         = "conference"
  api_swagger_link                 = "https://conferenceapi.azurewebsites.net/?format=json"
  product_id                       = module.tenant_a.product.product_id
  apim_name                        = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
  app_insights_resource_id         = module.tenant_a.app_insights.id
  app_insights_instrumentation_key = module.tenant_a.app_insights.instrumentation_key
}

//tenant b or team b
resource "azurerm_resource_group" "tenant_b_rg" {
  name     = var.tenant_b_rg
  location = var.tenant_b_rg_location
}

module "tenant_b" {
  source                      = "./modules/tenant/"
  tenant_name                 = "tenant-b"
  product_name                = "tenant-b-product"
  group_name                  = "tenant-b-group"
  apim_name                   = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name    = data.azurerm_api_management.apim_instance.resource_group_name
  law_workspace_id            = azurerm_log_analytics_workspace.main_law.id
  tenant_default_principal_id = var.tenant_b_default_principal_id
  tenant_resource_group_name  = azurerm_resource_group.tenant_b_rg.name
  tenant_location             = azurerm_resource_group.tenant_b_rg.location
}

//Conference API
module "team_b_api" {
  source                           = "./modules/tenant-api/"
  api_name                         = "team-b-conference-api-1"
  api_service_url                  = "https://conferenceapi.azurewebsites.net"
  api_path                         = "conferenceb"
  api_swagger_link                 = "https://conferenceapi.azurewebsites.net/?format=json"
  product_id                       = module.tenant_b.product.product_id
  apim_name                        = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
  app_insights_resource_id         = module.tenant_b.app_insights.id
  app_insights_instrumentation_key = module.tenant_b.app_insights.instrumentation_key
}

# //logic app action group
# module "app_insights_query_alert" {
#   source                     = "./modules/multi-resource-alert/"
#   alert_rule_name            = "APIM-APP-INSIGHTS-QUERY-ALERTS"
#   alert_rule_query           = <<-QUERY
#                                   requests
#                                     | project 
#                                       name,
#                                       operation_Name,
#                                       duration,
#                                       resultCode
#                                   QUERY
#   dimension_name             = "resultCode"
#   location                   = data.azurerm_api_management.apim_instance.location
#   resource_group_name        = data.azurerm_api_management.apim_instance.resource_group_name
#   app_insights_scope         = [module.conference_api.app_insights.id]
#   logic_apps_action_group_id = module.logic_app_action_group.action_group.id
# }


module "multi_app_insights_query_alert" {
  source                     = "./modules/multi-resource-alert/"
  alert_rule_name            = "ALL_SUB-APP-INSIGHTS-QUERY-ALERTS"
  alert_rule_query           = <<-QUERY
                                  AppRequests
                                    | project 
                                      Name,
                                      OperationName, 
                                      DurationMs,
                                      ResultCode
                                  QUERY
  dimension_name             = "ResultCode"
  location                   = data.azurerm_api_management.apim_instance.location
  resource_group_name        = data.azurerm_api_management.apim_instance.resource_group_name
  app_insights_scope         = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  logic_apps_action_group_id = module.logic_app_action_group.action_group.id
}




