
locals {
  tenant_tags = {
      tenant = var.tenant_name
      product = "${var.tenant_name}-product"
      group = "${var.tenant_name}-group"
      team = var.tenant_name
      environment = "dev"
      owner = var.tenant_name
      costCenter = var.tenant_cost_center
  }
  service_principal_name = "${upper(var.tenant_name)}-GRAFANA-APP"
}

# module "tenant-service-principal" {
#   source         = "../aad-service-principal"
#   tenant_name    = local.service_principal_name
#   app_owners_ids = [var.tenant_app_owner_id]
# }

data "azuread_application" "tenant_a_grafana_app" {
  display_name = "APIM_TENANT_A_GRAFANA_APP"
}

data "azuread_service_principal" "team_a_grafana_service_principal" {
  application_id = data.azuread_application.tenant_a_grafana_app.application_id
}

# resource "azurerm_role_assignment" "reader_log_analytics_workspace" {
#   scope                = var.law_workspace_id
#   role_definition_name = "Reader"
#   principal_id         = data.azuread_service_principal.team_a_grafana_service_principal.object_id  //module.tenant-service-principal.service_principal.object_id
#   skip_service_principal_aad_check = false  
# }

resource "azurerm_resource_group" "tenant_rg" {
  name     = var.tenant_rg
  location = var.tenant_location
  tags     = local.tenant_tags
}

resource "azurerm_role_assignment" "rg_assigments" {
  count =   length(var.tenant_principal_ids)
    scope                = azurerm_resource_group.tenant_rg.id
    role_definition_name = var.tenant_principal_ids[count.index].role
    principal_id         = var.tenant_principal_ids[count.index].principal_id
    skip_service_principal_aad_check = false 
}

resource "azurerm_role_assignment" "rg_assigments_service_principal" {
  scope                = azurerm_resource_group.tenant_rg.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = data.azuread_service_principal.team_a_grafana_service_principal.object_id  //module.tenant-service-principal.service_principal.object_id
  skip_service_principal_aad_check = false 
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
  tags                = local.tenant_tags
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "${var.tenant_name}-email-action-group"
  resource_group_name = azurerm_resource_group.tenant_rg.name
  short_name          = var.tenant_name

  email_receiver {
    name          = "sendtotenant"
    email_address = var.tenant_default_email_address
  }
  tags            = local.tenant_tags
}

//Temp: Sample APIs
module "conference" {
  source                           = "../tenant-api/"
  api_name                         = "${var.tenant_name}-conference-api"
  api_service_url                  = "https://conferenceapi.azurewebsites.net"
  api_path                         = "${var.tenant_name}-conference"
  # content_link                     = "https://conferenceapi.azurewebsites.net/?format=json"
  content_link                     =  "{\"swagger\":\"2.0\",\"info\":{\"title\":\"Demo Conference API ${var.tenant_name}\",\"description\":\"A sample API with information related to a technical conference.  The available resources  include *Speakers*, *Sessions* and *Topics*.  A single write operation is available to provide  feedback on a session.\",\"version\":\"2.0.0\"},\"host\":\"conferenceapi.azurewebsites.net\",\"schemes\":[\"http\",\"https\"],\"securityDefinitions\":{\"apiKeyHeader\":{\"type\":\"apiKey\",\"name\":\"Ocp-Apim-Subscription-Key\",\"in\":\"header\"},\"apiKeyQuery\":{\"type\":\"apiKey\",\"name\":\"subscription-key\",\"in\":\"query\"}},\"security\":[{\"apiKeyHeader\":[]},{\"apiKeyQuery\":[]}],\"paths\":{\"/sessions\":{\"get\":{\"description\":\"A list of sessions.  Optional parameters work as filters to reduce the listed sessions.\",\"operationId\":\"GetSessions\",\"parameters\":[{\"name\":\"speakername\",\"in\":\"query\",\"type\":\"string\"},{\"name\":\"dayno\",\"in\":\"query\",\"description\":\"Format - int32.\",\"type\":\"integer\"},{\"name\":\"keyword\",\"in\":\"query\",\"type\":\"string\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.collection+json\"]}},\"/session/{id}\":{\"get\":{\"description\":\"Retreive a representation of a single session by Id\",\"operationId\":\"GetSession\",\"parameters\":[{\"$ref\":\"#/parameters/id\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/hal+json\",\"text/plain\"]}},\"/session/{id}/topics\":{\"get\":{\"operationId\":\"GetSessionTopics\",\"description\":\"A list of topics covered by a particular session\",\"parameters\":[{\"$ref\":\"#/parameters/id\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.collection+json\"]}},\"/session/{id}/feedback\":{\"post\":{\"description\":\"Retreive a representation of a single session by Id\",\"operationId\":\"SubmitSession\",\"parameters\":[{\"$ref\":\"#/parameters/id\"},{\"name\":\"body\",\"in\":\"body\",\"required\":true,\"schema\":{\"type\":\"string\"}}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/hal+json\",\"text/plain\"],\"consumes\":[\"text/plain\"]}},\"/speakers\":{\"get\":{\"operationId\":\"GetSpeakers\",\"parameters\":[{\"name\":\"dayno\",\"in\":\"query\",\"description\":\"Format - int32.\",\"type\":\"integer\"},{\"name\":\"speakername\",\"in\":\"query\",\"type\":\"string\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.collection+json\"]}},\"/speaker/{id}\":{\"get\":{\"operationId\":\"GetSpeaker\",\"parameters\":[{\"$ref\":\"#/parameters/id\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.hal+json\",\"text/plain\"]}},\"/speaker/{id}/sessions\":{\"get\":{\"operationId\":\"GetSpeakerSessions\",\"parameters\":[{\"$ref\":\"#/parameters/id\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.collection+json\"]}},\"/speaker/{id}/topics\":{\"get\":{\"operationId\":\"GetSpeakerTopics\",\"parameters\":[{\"$ref\":\"#/parameters/id\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.collection+json\"]}},\"/topics\":{\"get\":{\"operationId\":\"GetTopics\",\"parameters\":[{\"name\":\"dayno\",\"in\":\"query\",\"required\":false,\"description\":\"Format - int32.\",\"type\":\"integer\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.collection+json\"]}},\"/topic/{id}\":{\"get\":{\"operationId\":\"GetTopic\",\"parameters\":[{\"$ref\":\"#/parameters/id\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/hal+json\"]}},\"/topic/{id}/speakers\":{\"get\":{\"operationId\":\"GetTopicSpeakers\",\"parameters\":[{\"$ref\":\"#/parameters/id\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.collection+json\"]}},\"/topic/{id}/sessions\":{\"get\":{\"operationId\":\"GetTopicSessions\",\"parameters\":[{\"$ref\":\"#/parameters/id\"}],\"responses\":{\"200\":{\"description\":\"OK\"}},\"produces\":[\"application/vnd.collection+json\"]}}},\"parameters\":{\"id\":{\"name\":\"id\",\"in\":\"path\",\"description\":\"Format - int32.\",\"required\":true,\"type\":\"integer\"}}}"
  content_type                     = "swagger-json"  
  apim_name                        = var.apim_name
  apim_resource_group_name         = var.apim_resource_group_name
  tenant_rg                        = azurerm_resource_group.tenant_rg.name
  tenant_product                   = azurerm_api_management_product.api_product.product_id
  tenant_ai_id                     = azurerm_application_insights.api_app_insights.id
  tenant_ai_instrumentation_key    = azurerm_application_insights.api_app_insights.instrumentation_key
}

//FakeRest API
# module "fakerest" {
#   source                           = "../tenant-api/"
#   api_name                         = "${var.tenant_name}-fakerest-api"
#   api_service_url                  = "https://fakerestapi.azurewebsites.net"
#   api_path                         = "${var.tenant_name}-fakerest"
#   content_link                     = "https://fakerestapi.azurewebsites.net/swagger/v1/swagger.json"
#   content_type                     = "openapi+json-link" 
#   apim_name                        = var.apim_name
#   apim_resource_group_name         = var.apim_resource_group_name
#   tenant_rg                        = azurerm_resource_group.tenant_rg.name
#   tenant_product                   = azurerm_api_management_product.api_product.product_id
#   tenant_ai_name                   = azurerm_application_insights.api_app_insights.name
# }



