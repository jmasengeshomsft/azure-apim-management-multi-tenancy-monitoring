
variable "apim_rg" {
  description = "The API Management Resource Group"
  type        = string
}

variable "apim_name" {
  description = "The API Management ID"
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

variable "tenant_a_rg" {
  description = "The resource group for the tenant A team"
  type        = string
}

variable "tenant_a_rg_location" {
  description = "The region for the tenant A team"
  type        = string
}

//tenant-b
variable "tenant_b_default_principal_id" {
  description = "The default principal ID for tenant-a. A user, group, or service principal that will be granted Reader access to the API App Insights"
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


        // {
        //     "type": "Microsoft.Web/connections",
        //     "apiVersion": "2016-06-01",
        //     "name": "[parameters('storage_account_name')]",
        //     "location": "[variables('location')]",
        //     "properties": {
        //         "api": {
        //             "id": "[subscriptionResourceId('Microsoft.Web/locations/managedApis', variables('location'), 'azuretables')]"
        //         },
        //         "parameterValues": {
        //             "accountName": "[parameters('storage_account_name')]",
        //             "accessKey": "[listKeys(parameters('storage_account_name'), '2017-07-01').keys[0].value]"
        //         }
        //     }
        // }