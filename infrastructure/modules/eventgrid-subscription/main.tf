
resource "azurerm_eventgrid_event_subscription" "subscription" {
  name  = var.azurerm_eventgrid_subscription_name
  scope = var.subscription_scope_id

  webhook_endpoint {
    url = var.webhook_endpoint_url
  }

  included_event_types = [
     "Microsoft.ApiManagement.APICreated",
  ]
}