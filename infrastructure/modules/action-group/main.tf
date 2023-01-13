resource "azurerm_resource_group_template_deployment" "arm_logic_app" {
  name                     = var.logic_app_name
  resource_group_name      = var.resource_group_name
  deployment_mode          = "Incremental"
  template_content         = file("${path.module}/arm-templates/logic-apps-arm.json")
  parameters_content       = jsonencode({
    "workflows_app1_alerts_name" = {
      value = var.logic_app_name
    }
    "connections_azuretables_name" = {
      value = var.connections_azuretables_name
    }
    "apim_instance_name" = {
      value = var.apim_instance_name
    }
  })
}

resource "azurerm_monitor_action_group" "app_insights_logic_app_action_group" {
  depends_on = [
    azurerm_resource_group_template_deployment.arm_logic_app
  ]
  name                = "AppInsights-LogicApp-ActionGroup"
  resource_group_name = var.resource_group_name
  short_name          = "apim-alerts"

  email_receiver {
    name          = "sendtoadmin"
    email_address = var.email_address
  }

  logic_app_receiver {
    name                    = var.logic_app_name
    resource_id             =  jsondecode(azurerm_resource_group_template_deployment.arm_logic_app.output_content).logicAppsResourceId.value 
    callback_url            =  jsondecode(azurerm_resource_group_template_deployment.arm_logic_app.output_content).logicAppsCallBackUrl.value
    use_common_alert_schema = true
  }
}


