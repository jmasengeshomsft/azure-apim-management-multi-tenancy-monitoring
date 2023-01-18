variable "tenant_name" {
    description = "The name of product"
    type        = string
}

variable "product_name" {
    description = "The name of product"
    type        = string
}

variable "group_name" {
    description = "The name of the group"
    type        = string
}

variable "apim_name" {
    description = "The API Management Name"
    type        = string
}

variable "apim_resource_group_name" {
    description = "The API Management Resource Group Name"
    type        = string
}

variable "law_workspace_id" {
    description = "The LAW Workspace Id"
    type        = string
}

variable "tenant_principal_ids" {
    description = "User, Group, or Service Principal Id that will be granted Reader access to the API App Insights"
    type = list(object({
        principal_id                     = string
        role                             = string 
        skip_service_principal_aad_check = bool                 
    }))
    default = []
}

variable "tenant_rg" {
  description = "The resource group for the tenant A team"
  type        = string
}

variable "tenant_location" {
    description = "The tenant location"
    type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     =  {
  }
}

