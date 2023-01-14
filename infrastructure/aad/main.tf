module "tenant-a-grafana-service-principal" {
  source                = "../modules/aad-service-principal/"
  tenant_name           = var.tenant_a_name
  app_owners_ids        = [data.azuread_client_config.current.object_id]
}

module "tenant-b-grafana-service-principal" {
  source                = "../modules/aad-service-principal/"
  tenant_name           = var.tenant_b_name
  app_owners_ids        = [data.azuread_client_config.current.object_id]
}
