resource "azuread_group" "aad_group" {
  display_name            = var.tenant_name
  owners                  = var.app_owners_ids
  security_enabled        = true
  prevent_duplicate_names = true
}

# locals {
#   azuread_admin_group_mail_nickname = uuidv5("dns", "ca.dev.xyz")
#   # azuread_admin_group_owners        = concat([data.azuread_service_principal.terraform_client.id], data.azuread_user.admin_user.*.id)
#   # azuread_admin_group_id           = shell_script.azuread_admin_group.output.id
# }

# provider "shell" {
  
# }

# resource "shell_script" "azuread_admin_group" {
#   lifecycle_commands {
#     create = "az ad group create --display-name ${var.tenant_name} --mail-nickname ${local.azuread_admin_group_mail_nickname}"
#     # read   = "az ad group show --group ${var.azuread_admin_group_name}"
#     # update = "az ad group delete --group ${var.azuread_admin_group_name} && az ad group create --display-name ${var.azuread_admin_group_name} --mail-nickname ${local.azuread_admin_group_mail_nickname}"
#     # delete = "az ad group delete --group ${var.azuread_admin_group_name}"
#   }
# }