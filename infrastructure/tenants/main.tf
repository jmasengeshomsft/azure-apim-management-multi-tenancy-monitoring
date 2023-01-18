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
  tags                        = var.tenant_a_tags
}

resource "azurerm_monitor_action_group" "tenant_a_action_group" {
  name                = "tenant-a-email-action-group"
  resource_group_name = module.tenant_a.tenant_rg.name
  short_name          = "tenant-a-ag"

  email_receiver {
    name          = "sendtoadmin"
    email_address = var.tenant_a_default_email_address
  }
  tags            = var.tenant_a_tags
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
  tags                        = var.tenant_b_tags
}

resource "azurerm_monitor_action_group" "tenant_b_action_group" {
  name                = "tenant-b-email-action-group"
  resource_group_name = module.tenant_b.tenant_rg.name
  short_name          = "tenant-b-ag"

  email_receiver {
    name          = "sendtoadmin"
    email_address = var.tenant_b_default_email_address
  }
  tags            = var.tenant_b_tags
}


resource "azurerm_monitor_metric_alert" "requests" {
  name                = "tenant-b-request-count-alert"
  resource_group_name = module.tenant_b.tenant_rg.name
  scopes              = [module.tenant_b.app_insights.id]
  description         = "Action will be triggered when request countt is greater than 5."
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "performanceCounters/requestsPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 3

    dimension {
      name     = "cloud/roleInstance"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.tenant_b_action_group.id
  }

  tags        = var.tenant_b_tags
}
