data "azurerm_api_management" "apim_instance" {
  name                = var.apim_name
  resource_group_name = var.apim_rg
}


//Conference API
module "team_a_api" {
  source                           = "../modules/tenant-api/"
  api_name                         = "team-a-conference-api"
  api_service_url                  = "https://conferenceapi.azurewebsites.net"
  api_path                         = "conference"
  api_swagger_link                 = "https://conferenceapi.azurewebsites.net/?format=json"
  apim_name                        = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
  tenant_rg                        = var.tenant_a_rg
  tenant_product                   = "${var.tenant_a_name}-product"
  tenant_ai_name                   = "${var.tenant_a_name}-appinsights"
}

//Petstore API
module "team_b_api" {
  source                           = "../modules/tenant-api/"
  api_name                         = "team-b-petstore-api"
  api_service_url                  = "https://petstore.swagger.io/v2"
  api_path                         = "petstore"
  api_swagger_link                 = "https://petstore.swagger.io/v2/swagger.json"
  apim_name                        = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
  tenant_rg                        = var.tenant_b_rg
  tenant_product                   = "${var.tenant_b_name}-product"
  tenant_ai_name                   = "${var.tenant_b_name}-appinsights"
}