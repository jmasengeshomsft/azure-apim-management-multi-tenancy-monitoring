
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
  source                                  = "./modules/table-storage/"
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
  source              = "./modules/action-group/"
  email_address       = var.admin_email_address
  resource_group_name = data.azurerm_api_management.apim_instance.resource_group_name
  connections_azuretables_name = "AzureTablesConnection"
  apim_instance_name = data.azurerm_api_management.apim_instance.name
}

module "multi_app_insights_query_alert" {
  source                     = "./modules/multi-resource-alert/"
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

//tenant or team A
# resource "azurerm_resource_group" "tenant_a_rg" {
#   name     = var.tenant_a_rg
#   location = var.tenant_a_rg_location
# }

data "azuread_application" "tenant_a_grafana_app" {
  display_name = var.tenant_a_grafana_app_name
}

data "azuread_service_principal" "team_a_grafana_service_principal" {
  application_id = data.azuread_application.tenant_a_grafana_app.application_id
}

# resource "azurerm_role_assignment" "grafana_tenant_a_reader_log_analytics_workspace" {
#     scope                            = azurerm_log_analytics_workspace.main_law.id
#     role_definition_name             = "Reader"
#     principal_id                     =data.azuread_service_principal.team_a_grafana_service_principal.object_id
#     skip_service_principal_aad_check = false 
# }


# module "tenant_a" {
#   depends_on = [
#     module.reference_data_table_storage,
#     module.multi_app_insights_query_alert,
#     azurerm_log_analytics_workspace.main_law
#   ]
#   source                      = "./modules/tenant/"
#   tenant_name                 = "tenant-a"
#   product_name                = "tenant-a-product"
#   group_name                  = "tenant-a-group"
#   apim_name                   = data.azurerm_api_management.apim_instance.name
#   apim_resource_group_name    = data.azurerm_api_management.apim_instance.resource_group_name
#   law_workspace_id            = azurerm_log_analytics_workspace.main_law.id
#   tenant_principal_ids        = [  
#                                   {
#                                     principal_id  = var.tenant_a_default_principal_id
#                                     role          = "Reader",
#                                     skip_service_principal_aad_check = true
#                                   },
#                                   {
#                                     principal_id  = data.azuread_service_principal.team_a_grafana_service_principal.object_id
#                                     role          = "Log Analytics Reader",
#                                     skip_service_principal_aad_check = true
#                                   }
#                                 ]
#   tenant_a_rg                 = var.tenant_a_rg
#   tenant_location             = var.tenant_a_rg_location
# }

//Conference API
# module "team_a_api" {
#   source                           = "./modules/tenant-api/"
#   api_name                         = "team-a-conference-api"
#   api_service_url                  = "https://conferenceapi.azurewebsites.net"
#   api_path                         = "conference"
#   api_swagger_link                 = "https://conferenceapi.azurewebsites.net/?format=json"
#   product_id                       = module.tenant_a.product.product_id
#   apim_name                        = data.azurerm_api_management.apim_instance.name
#   apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
#   app_insights_resource_id         = module.tenant_a.app_insights.id
#   app_insights_instrumentation_key = module.tenant_a.app_insights.instrumentation_key
# }

//tenant b or team b
# resource "azurerm_resource_group" "tenant_b_rg" {
#   name     = var.tenant_b_rg
#   location = var.tenant_b_rg_location
# }

data "azuread_application" "tenant_b_grafana_app" {
  display_name = var.tenant_b_grafana_app_name
}

data "azuread_service_principal" "team_b_grafana_service_principal" {
  application_id = data.azuread_application.tenant_b_grafana_app.application_id
}

# resource "azurerm_role_assignment" "grafana_tenant_b_reader_log_analytics_workspace" {
#     scope                            = azurerm_log_analytics_workspace.main_law.id
#     role_definition_name             = "Reader"
#     principal_id                     = data.azuread_service_principal.team_b_grafana_service_principal.object_id
#     skip_service_principal_aad_check = false 
# }


# module "tenant_b" {
#    depends_on = [
#     module.reference_data_table_storage,
#     module.multi_app_insights_query_alert,
#     azurerm_log_analytics_workspace.main_law
#   ]
#   source                      = "./modules/tenant/"
#   tenant_name                 = "tenant-b"
#   product_name                = "tenant-b-product"
#   group_name                  = "tenant-b-group"
#   apim_name                   = data.azurerm_api_management.apim_instance.name
#   apim_resource_group_name    = data.azurerm_api_management.apim_instance.resource_group_name
#   law_workspace_id            = azurerm_log_analytics_workspace.main_law.id
#   tenant_principal_ids        = [  
#                                   {
#                                     principal_id  = var.tenant_b_default_principal_id
#                                     role          = "Reader",
#                                     skip_service_principal_aad_check = true
#                                   },
#                                   {
#                                     principal_id  = data.azuread_service_principal.team_b_grafana_service_principal.object_id
#                                     role          = "Log Analytics Reader",
#                                     skip_service_principal_aad_check = true
#                                   }
#                                 ]
#   tenant_a_rg                 = var.tenant_b_rg
#   tenant_location             = var.tenant_b_rg_location
# }

//PetStore API
# module "team_b_api" {
#   source                           = "./modules/tenant-api/"
#   api_name                         = "team-b-petstore-api"
#   api_service_url                  = "https://petstore.swagger.io/v2"
#   api_path                         = "petstore"
#   api_swagger_link                 = "https://petstore.swagger.io/v2/swagger.json"
#   product_id                       = module.tenant_b.product.product_id
#   apim_name                        = data.azurerm_api_management.apim_instance.name
#   apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
#   app_insights_resource_id         = module.tenant_b.app_insights.id
#   app_insights_instrumentation_key = module.tenant_b.app_insights.instrumentation_key
# }

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







