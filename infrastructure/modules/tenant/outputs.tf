
output "product" {
  value = azurerm_api_management_product.api_product
}

output "group" {
  value = azurerm_api_management_group.api_group
}

output "app_insights" {
  value = azurerm_application_insights.api_app_insights
}

output "tenant_rg" {
  value = azurerm_resource_group.tenant_rg
}


