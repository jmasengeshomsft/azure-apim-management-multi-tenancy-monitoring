data "azurerm_api_management" "apim_instance" {
  name                = var.apim_name
  resource_group_name = var.apim_rg
}

//-----------TENANT A APIS----------------
//Conference API
module "team_a_api-conference" {
  source                           = "../modules/tenant-api/"
  api_name                         = "team-a-conference-api"
  api_service_url                  = "https://conferenceapi.azurewebsites.net"
  api_path                         = "conference"
  content_link                     = "https://conferenceapi.azurewebsites.net/?format=json"
  content_type                     = "swagger-link-json"   
  apim_name                        = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
  tenant_rg                        = var.tenant_a_rg
  tenant_product                   = "${var.tenant_a_name}-product"
  tenant_ai_name                   = "${var.tenant_a_name}-appinsights"
}

//FakeRest API
module "team_a_api-fakerest" {
  source                           = "../modules/tenant-api/"
  api_name                         = "team-a-fakerest-api"
  api_service_url                  = "https://fakerestapi.azurewebsites.net"
  api_path                         = "fakerest"
  content_link                     = "https://fakerestapi.azurewebsites.net/swagger/v1/swagger.json"
  content_type                     = "openapi+json-link" 
  apim_name                        = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
  tenant_rg                        = var.tenant_a_rg
  tenant_product                   = "${var.tenant_a_name}-product"
  tenant_ai_name                   = "${var.tenant_a_name}-appinsights"
}

module "team_a_api-fakerest1" {
  source                           = "../modules/tenant-api/"
  api_name                         = "team-a-fakerest-api-1"
  api_service_url                  = "https://fakerestapi.azurewebsites.net"
  api_path                         = "fakerest-1"
  content_link                     = "https://fakerestapi.azurewebsites.net/swagger/v1/swagger.json"
  content_type                     = "openapi+json-link" 
  apim_name                        = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
  tenant_rg                        = var.tenant_a_rg
  tenant_product                   = "${var.tenant_a_name}-product"
  tenant_ai_name                   = "${var.tenant_a_name}-appinsights"
}

//---------TENANT B APIS-------------------------
//Petstore API
module "team_b_api" {
  source                           = "../modules/tenant-api/"
  api_name                         = "team-b-petstore-api"
  api_service_url                  = "https://petstore.swagger.io/v2"
  api_path                         = "petstore"
  content_link                     = "https://petstore.swagger.io/v2/swagger.json"
  content_type                     = "swagger-link-json" 
  apim_name                        = data.azurerm_api_management.apim_instance.name
  apim_resource_group_name         = data.azurerm_api_management.apim_instance.resource_group_name
  tenant_rg                        = var.tenant_b_rg
  tenant_product                   = "${var.tenant_b_name}-product"
  tenant_ai_name                   = "${var.tenant_b_name}-appinsights"
}