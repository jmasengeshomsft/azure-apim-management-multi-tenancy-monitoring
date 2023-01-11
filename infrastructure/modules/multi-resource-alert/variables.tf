
variable "alert_rule_name" {
    description = "The name of the alert rule"
    type        = string
}

variable "alert_rule_query" {
    description = "The query of the alert rule"
    type        = string
}

variable "dimension_name" {
    description = "The dimension name"
    type        = string
}

variable "location" {
    description = "The API Management Location"
    type        = string
}

variable "resource_group_name" {
    description = "The API Management Resource Group Name"
    type        = string
}

variable "logic_apps_action_group_id" {
    description = "The ID of the action group"
    type        = string
}

variable "evaluation_frequency" {
    description = "Rule evaluation frequency"
    type        = string
    default     = "PT5M"
}

variable "window_duration" {
    description = "Rule window duration"
    type        = string
    default     = "PT5M"
}

variable "app_insights_scope" {
    description = "app insights scope"
    type       = list(string)
    default = [ ]
}


variable "app_insights_type" {
    description = "app insights type"
    type        = string
    default     = "microsoft.insights/components"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     =  {
      "appName" = "apim-alerts"
  }
}
