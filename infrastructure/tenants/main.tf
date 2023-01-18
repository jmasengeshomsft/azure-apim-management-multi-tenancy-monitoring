data "azurerm_api_management" "apim_instance" {
  name                = var.apim_name
  resource_group_name = var.apim_rg
}

data "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  resource_group_name = var.law_rg
}

//TENANT A MODULE
data "azuread_application" "tenant_a_grafana_app" {
  display_name = var.tenant_a_grafana_app_name
}

data "azuread_service_principal" "team_a_grafana_service_principal" {
  application_id = data.azuread_application.tenant_a_grafana_app.application_id
}

resource "azurerm_role_assignment" "grafana_tenant_a_reader_log_analytics_workspace" {
    scope                            = data.azurerm_log_analytics_workspace.law.id
    role_definition_name             = "Reader"
    principal_id                     = data.azuread_service_principal.team_a_grafana_service_principal.object_id
    skip_service_principal_aad_check = false 
}

module "tenant_a" { 
  source                      = "../modules/tenant"
  tenant_name                 = "tenant-a"
  product_name                = "tenant-a-product"
  group_name                  = "tenant-a-group"
  apim_name                   = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name    = data.azurerm_api_management.apim_instance.resource_group_name
  law_workspace_id            = data.azurerm_log_analytics_workspace.law.id
  tenant_principal_ids        = [  
                                  {
                                    principal_id  = var.tenant_a_default_principal_id
                                    role          = "Reader",
                                    skip_service_principal_aad_check = true
                                  },
                                  {
                                    principal_id  = data.azuread_service_principal.team_a_grafana_service_principal.object_id
                                    role          = "Log Analytics Reader",
                                    skip_service_principal_aad_check = true
                                  }
                                ]
  tenant_rg                   = var.tenant_a_rg
  tenant_location             = var.tenant_a_rg_location
}

//TENANT B MODULE
data "azuread_application" "tenant_b_grafana_app" {
  display_name = var.tenant_b_grafana_app_name
}

data "azuread_service_principal" "team_b_grafana_service_principal" {
  application_id = data.azuread_application.tenant_b_grafana_app.application_id
}

resource "azurerm_role_assignment" "grafana_tenant_b_reader_log_analytics_workspace" {
    scope                            = data.azurerm_log_analytics_workspace.law.id
    role_definition_name             = "Reader"
    principal_id                     = data.azuread_service_principal.team_b_grafana_service_principal.object_id
    skip_service_principal_aad_check = false 
}

module "tenant_b" {
  source                      = "../modules/tenant/"
  tenant_name                 = "tenant-b"
  product_name                = "tenant-b-product"
  group_name                  = "tenant-b-group"
  apim_name                   = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name    = data.azurerm_api_management.apim_instance.resource_group_name
  law_workspace_id            = data.azurerm_log_analytics_workspace.law.id
  tenant_principal_ids        = [  
                                  {
                                    principal_id  = var.tenant_b_default_principal_id
                                    role          = "Reader",
                                    skip_service_principal_aad_check = true
                                  },
                                  {
                                    principal_id  = data.azuread_service_principal.team_b_grafana_service_principal.object_id
                                    role          = "Log Analytics Reader",
                                    skip_service_principal_aad_check = true
                                  }
                                ]
  tenant_rg                   = var.tenant_b_rg
  tenant_location             = var.tenant_b_rg_location
}
