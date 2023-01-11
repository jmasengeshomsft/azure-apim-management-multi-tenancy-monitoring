provider "azurerm" {
  # # version = ">=3.0.0"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "sre-rg"
#     storage_account_name = "jmtfstatestr"
#     container_name       = "apim-sh-gateway"
#     key                  = "apim-sh-gateway.tfstate"
#   }
# }

terraform {
  required_version = ">= 0.12"
}

# Make client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}
