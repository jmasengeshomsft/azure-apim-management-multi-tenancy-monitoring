provider "azurerm" {
  # # version = ">=3.0.0"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.7.0"
    }
  }
}

# Configure the Azure Active Directory Provider
provider "azuread" {

  # NOTE: Environment Variables can also be used for Service Principal authentication
  # Terraform also supports authenticating via the Azure CLI too.
  # See official docs for more info: https://registry.terraform.io/providers/hashicorp/azuread/latest/docs

  # client_id     = "..."
  # client_secret = "..."
  # tenant_id     = "..."
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
data "azuread_client_config" "current" {}
