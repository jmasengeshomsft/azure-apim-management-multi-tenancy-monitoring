
resource "azurerm_resource_group" "tenant_rg" {
  name     = var.tenant_rg
  location = var.tenant_location
}

resource "azurerm_api_management_group" "api_group" {
  name                = var.group_name
  api_management_name = var.apim_name
  resource_group_name = var.apim_resource_group_name
  display_name        = var.group_name
  description         = var.group_name
}

resource "azurerm_api_management_product" "api_product" {
  product_id            = var.product_name
  api_management_name   = var.apim_name
  resource_group_name   = var.apim_resource_group_name
  display_name          = var.product_name
  description           = var.product_name
  subscription_required = true
  subscriptions_limit   = 2
  approval_required     = true
  published             = true
}

resource "azurerm_api_management_product_group" "product_group" {
  product_id          = azurerm_api_management_product.api_product.product_id
  group_name          = azurerm_api_management_group.api_group.name
  api_management_name = var.apim_name
  resource_group_name = var.apim_resource_group_name
}

resource "azurerm_application_insights" "api_app_insights" {
  name                = "${var.tenant_name}-appinsights"
  location            = var.tenant_location
  workspace_id        = var.law_workspace_id
  resource_group_name = azurerm_resource_group.tenant_rg.name
  application_type    = "other"
}

resource "azurerm_role_assignment" "array_api_app_insights_reader" {
  count =   length(var.tenant_principal_ids)
    scope                = azurerm_application_insights.api_app_insights.id
    role_definition_name = var.tenant_principal_ids[count.index].role
    principal_id         = var.tenant_principal_ids[count.index].principal_id
    skip_service_principal_aad_check = false 
}


