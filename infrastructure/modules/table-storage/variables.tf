
variable "storage_account_name" {
    description = "The name of the storage account"
    type        = string
}


variable "location" {
    description = "The API Management Location"
    type        = string
}

variable "resource_group_name" {
    description = "The API Management Resource Group Name"
    type        = string
}

variable "connections_azuretables_name" {
    description = "The storage account table connection name"
    type        = string
}

variable "azurerm_eventgrid_subscription_name" {
    description = "The name of the event grid subscription"
    type        = string
}

variable "default_admin_email" {
    description = "Default Admin Email Address"
    type        = string
}

variable "subscription_scope_id" {
    description = "The scope of the event grid subscription"
    type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     =  {
      "appName" = "apim-alerts"
  }
}
