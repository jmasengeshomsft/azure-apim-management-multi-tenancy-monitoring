data "azurerm_api_management" "apim_instance" {
  name                = var.apim_name
  resource_group_name = var.apim_rg
}

data "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  resource_group_name = var.law_rg
}

//TENANT A MODULE
# data "azuread_application" "tenant_a_grafana_app" {
#   display_name = "TENANT_0_GRAFANA_APP"
# }

# data "azuread_service_principal" "team_a_grafana_service_principal" {
#   application_id = data.azuread_application.tenant_a_grafana_app.application_id
# }

# resource "azurerm_role_assignment" "grafana_tenant_a_reader_log_analytics_workspace" {
#     scope                            = data.azurerm_log_analytics_workspace.law.id
#     role_definition_name             = "Reader"
#     principal_id                     = data.azuread_service_principal.team_a_grafana_service_principal.object_id
#     skip_service_principal_aad_check = false 
# }

# module "tenant-service-principal" {
#   source         = "../modules/aad-service-principal"
#   tenant_name    = "TENANT_0_GRAFANA_APP"
#   app_owners_ids = [data.azuread_client_config.current.object_id]
# }

module "tenant" { 
  # depends_on = [
  #   module.tenant-service-principal
  # ]
  count = 2
    source                        = "../modules/tenant"
    tenant_name                   = "tenant-${count.index}"
    product_name                  = "tenant-${count.index}-product"
    group_name                    = "tenant-${count.index}-group"
    apim_name                     = data.azurerm_api_management.apim_instance.name
    apim_resource_group_name      = data.azurerm_api_management.apim_instance.resource_group_name
    law_workspace_id              = data.azurerm_log_analytics_workspace.law.id
    tenant_principal_ids          = [  
                                      {
                                        principal_id  = var.tenant_a_default_principal_id
                                        role          = "Reader",
                                        skip_service_principal_aad_check = true
                                        type          = "User"
                                      }
                                    ]
    tenant_rg                     = "tenant-${count.index}-rg"
    tenant_location               = var.tenant_a_rg_location
    tenant_default_email_address  = var.tenant_a_default_email_address
    tenant_cost_center            = "1000-${count.index}"
    tenant_service_principal_name = "TENANT_0_GRAFANA_APP"
}


# module "tenant_a" { 
#   source                        = "../modules/tenant"
#   tenant_name                   = "tenant-a"
#   product_name                  = "tenant-a-product"
#   group_name                    = "tenant-a-group"
#   apim_name                     = data.azurerm_api_management.apim_instance.name
#   apim_resource_group_name      = data.azurerm_api_management.apim_instance.resource_group_name
#   law_workspace_id              = data.azurerm_log_analytics_workspace.law.id
#   tenant_principal_ids          = [  
#                                     {
#                                       principal_id  = var.tenant_a_default_principal_id
#                                       role          = "Reader",
#                                       skip_service_principal_aad_check = true
#                                       type          = "User"
#                                     }
#                                   ]
#   tenant_rg                     = var.tenant_a_rg
#   tenant_location               = var.tenant_a_rg_location
#   tenant_default_email_address  = var.tenant_a_default_email_address
#   tenant_cost_center            = "1234"
#   tenant_app_owner_id           = data.azuread_client_config.current.object_id
# }

# module "tenant_b" {
#   source                        = "../modules/tenant/"
#   tenant_name                   = "tenant-b"
#   product_name                  = "tenant-b-product"
#   group_name                    = "tenant-b-group"
#   apim_name                     = data.azurerm_api_management.apim_instance.name
#   apim_resource_group_name      = data.azurerm_api_management.apim_instance.resource_group_name
#   law_workspace_id              = data.azurerm_log_analytics_workspace.law.id
#   tenant_principal_ids          = [  
#                                     {
#                                       principal_id  = var.tenant_b_default_principal_id
#                                       role          = "Reader",
#                                       skip_service_principal_aad_check = true
#                                       type          = "User"
#                                     }
#                                   ]
#   tenant_rg                     = var.tenant_b_rg
#   tenant_location               = var.tenant_b_rg_location
#   tenant_default_email_address  = var.tenant_b_default_email_address
#   tenant_cost_center            = "5678"
#   tenant_app_owner_id           = data.azuread_client_config.current.object_id
# }

# resource "azurerm_monitor_metric_alert" "requests" {
#   name                = "tenant-b-request-count-alert"
#   resource_group_name = module.tenant_b.tenant_rg.name
#   scopes              = [module.tenant_b.app_insights.id]
#   description         = "Action will be triggered when request countt is greater than 5."
#   frequency           = "PT1M"
#   window_size         = "PT5M"

#   criteria {
#     metric_namespace = "microsoft.insights/components"
#     metric_name      = "performanceCounters/requestsPerSecond"
#     aggregation      = "Average"
#     operator         = "GreaterThan"
#     threshold        = 3

#     dimension {
#       name     = "cloud/roleInstance"
#       operator = "Include"
#       values   = ["*"]
#     }
#   }

#   action {
#     action_group_id = module.tenant_b.email_action_group.id
#   }

#   tags        = var.tenant_b_tags
# }
