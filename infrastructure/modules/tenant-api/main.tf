resource "azurerm_api_management_api" "tenant_api" {
  name                = var.api_name
  resource_group_name = var.apim_resource_group_name
  api_management_name = var.apim_name
  service_url         = var.api_service_url
  revision            = "1"
  display_name        = var.api_name
  path                = var.api_path
  protocols           = ["https", "http"]

  import {
    content_format = "swagger-link-json"
    content_value  = var.api_swagger_link
  }
}

resource "azurerm_api_management_product_api" "product_api" {
  api_name            = azurerm_api_management_api.tenant_api.name
  product_id          = var.product_id
  api_management_name = var.apim_name
  resource_group_name = var.apim_resource_group_name
}


# resource "azurerm_application_insights" "api_app_insights" {
#   name                = "${azurerm_api_management_api.tenant_api.name}-appinsights"
#   location            = var.tenant_location
#   workspace_id        = var.law_workspace_id
#   resource_group_name = var.tenant_resource_group_name
#   application_type    = "other"
# }

# resource "azurerm_role_assignment" "api_app_insights_reader" {
#   scope                = azurerm_application_insights.api_app_insights.id
#   role_definition_name = "Reader"
#   principal_id         = var.api_app_insights_reader_principal_id
# }


resource "azurerm_api_management_logger" "api_logger" {
  name                = "${azurerm_api_management_api.tenant_api.name}-logger"
  api_management_name = var.apim_name
  resource_group_name = var.apim_resource_group_name
  resource_id         = var.app_insights_resource_id

  application_insights {
    instrumentation_key = var.app_insights_instrumentation_key
  }
}

resource "azurerm_api_management_api_diagnostic" "api_diagnostic" {
  identifier               = "applicationinsights"
  resource_group_name      = var.apim_resource_group_name
  api_management_name      = var.apim_name
  api_name                 = azurerm_api_management_api.tenant_api.name
  api_management_logger_id = azurerm_api_management_logger.api_logger.id

  sampling_percentage       = 100.0
  always_log_errors         = true
  log_client_ip             = true
  verbosity                 = "verbose"
  http_correlation_protocol = "W3C"

  frontend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  frontend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }

  backend_request {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "accept",
      "origin",
    ]
  }

  backend_response {
    body_bytes = 32
    headers_to_log = [
      "content-type",
      "content-length",
      "origin",
    ]
  }
}

