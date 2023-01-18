// API
variable "api_name" {
    description = "The API Name"
    type        = string
}

variable "api_service_url" {
    description = "The API Service Url"
    type        = string
}

variable "api_path" {
    description = "The API path"
    type        = string
}

variable "api_swagger_link" {
    description = "The API Swagger_link"
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

variable "tenant_product" {
    description = "The Product Id"
    type        = string
}

variable "tenant_ai_name" {
    description = "The AI Id"
    type        = string
}

variable "tenant_rg" {
    description = "The tenant resource group"
    type        = string
}