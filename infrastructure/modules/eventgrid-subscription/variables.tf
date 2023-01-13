
variable "azurerm_eventgrid_subscription_name" {
    description = "The name of the event grid subscription"
    type        = string
}


variable "subscription_scope_id" {
    description = "The scope of the event grid subscription"
    type        = string
}

variable "webhook_endpoint_url" {
    description = "The webhook endpoint url"
    type        = string
}

