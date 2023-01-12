
variable "logic_app_name" {
    description = "The name of the logic apps"
    type        = string
    default     = "apim-alerts-broadcast"
}

variable "email_address" {
    description = "Admin email address"
    type        = string
}

variable "resource_group_name" {
    description = "The API Management Resource Group Name"
    type        = string
}

variable "storage_account_name" {
    description = "The name of the storage account"
    type        = string
}

