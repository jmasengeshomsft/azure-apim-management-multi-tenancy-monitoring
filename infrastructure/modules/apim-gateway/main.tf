resource "azurerm_api_management_gateway" "apim_gateway" {
  name              = var.apim_gateway_name
  api_management_id = var.apim_id
  description       =var.apim_gateway_description

  location_data {
    name     = var.apim_gateway_region
    city     = "example city"
    district = "example district"
    region   = var.apim_gateway_region
  }
}