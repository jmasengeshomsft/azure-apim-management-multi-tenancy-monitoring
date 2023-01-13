
output "storage_account" {
  value = azurerm_storage_account.account
}

output logic_apps {
  value = jsondecode(azurerm_resource_group_template_deployment.ref_data_logic_app.output_content).logicAppsResourceId.value
}

output logic_apps_callback {
  value = jsondecode(azurerm_resource_group_template_deployment.ref_data_logic_app.output_content).logicAppsCallBackUrl.value
}

