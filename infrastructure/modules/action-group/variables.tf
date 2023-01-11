
variable "logic_app_name" {
    description = "The name of the logic apps"
    type        = string
    default     = "apim-alerts-broadcasting-logic-apps"
}

variable "email_address" {
    description = "Admin email address"
    type        = string
}

variable "resource_group_name" {
    description = "The API Management Resource Group Name"
    type        = string
}

variable "location" {
    description = "The location of the resource group"
    type        = string
}
