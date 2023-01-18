
variable "tenant_name" {
    description = "The name of the tenant which will use the service principal"
    type        = string
}
variable "app_owners_ids" {
  description = "value of the owner of the app"
  type        = list(string)
}