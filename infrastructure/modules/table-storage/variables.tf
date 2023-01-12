
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

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     =  {
      "appName" = "apim-alerts"
  }
}
