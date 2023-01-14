resource "azuread_application" "garafana_app" {
  display_name = "${var.tenant_name}_GRAFANA_APP"
  owners       = var.app_owners_ids
}

resource "azuread_service_principal" "grafana_principal" {
  application_id               = azuread_application.garafana_app.application_id
  app_role_assignment_required = false
  owners                       = var.app_owners_ids
}