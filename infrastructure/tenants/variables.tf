
variable "apim_rg" {
  description = "The API Management Resource Group"
  type        = string
}

variable "apim_name" {
  description = "The API Management ID"
  type        = string
}

variable "law_name" {
  description = "The name of the log analytics workspace"
  type        = string
}

variable "law_rg" {
  description = "The resource group of the log analytics workspace"
  type        = string
}

variable "admin_email_address" {
  description = "The email to sent alerts to in top of the logic apps if desired"
  type        = string
}

variable "reference_data_storage_account_name" {
  description = "Storage Account for Reference Data"
  type        = string
}


//tenant-a
variable "tenant_a_default_principal_id" {
  description = "The default principal ID for tenant-a. A user, group, or service principal that will be granted Reader access to the API App Insights"
  type        = string
}

variable "tenant_a_default_email_address" {
  description = "The default email to be used in the action group"
  type        = string
}

variable "tenant_a_grafana_app_name" {
  description = "The Grafana app name for tenant B"
  type        = string
}

variable "tenant_a_rg" {
  description = "The resource group for the tenant A team"
  type        = string
}

variable "tenant_a_rg_location" {
  description = "The region for the tenant A team"
  type        = string
}

variable "tenant_a_tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {
                                  tenant = "tenant-a"
                                  product = "tenant-a-product"
                                  group = "tenant-a-group"
                                  team = "tenant-a-team"
                                  environment = "dev"
                                  owner = "tenant-a-team"
                                  costCenter = "123"
  }
}

//tenant-b
variable "tenant_b_default_principal_id" {
  description = "The default principal ID for tenant-a. A user, group, or service principal that will be granted Reader access to the API App Insights"
  type        = string
}

variable "tenant_b_grafana_app_name" {
  description = "The Grafana app name for tenant B"
  type        = string
}


variable "tenant_b_default_email_address" {
  description = "The default email to be used in the action group"
  type        = string
}

variable "tenant_b_rg" {
  description = "The resource group for the tenant A team"
  type        = string
}

variable "tenant_b_rg_location" {
  description = "The region for the tenant A team"
  type        = string
}
variable "tenant_b_tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {
                                  tenant = "tenant-b"
                                  product = "tenant-b-product"
                                  group = "tenant-b-group"
                                  team = "tenant-b-team"
                                  environment = "dev"
                                  owner = "tenant-b-team"
                                  costCenter = "5678"
  }
}