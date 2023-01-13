
output "action_group" {
  value = azurerm_monitor_action_group.app_insights_logic_app_action_group
}

output logic_apps {
  value = jsondecode(azurerm_resource_group_template_deployment.arm_logic_app.output_content).logicAppsResourceId.value
}

output logic_apps_callback {
  value = jsondecode(azurerm_resource_group_template_deployment.arm_logic_app.output_content).logicAppsCallBackUrl.value
}