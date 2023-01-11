resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert" {
  name                = var.alert_rule_name
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency    = var.evaluation_frequency
  window_duration         = var.window_duration
  scopes                  = var.app_insights_scope
  target_resource_types   = [var.app_insights_type] 
  severity                = 4
  criteria {
   query  =  var.alert_rule_query
    time_aggregation_method = "Count"
    threshold               = 5
    operator                = "GreaterThan"
    dimension {
      name     = var.dimension_name
      operator = "Exclude"
      values   = ["200"]
    }

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  auto_mitigation_enabled          = true
  workspace_alerts_storage_enabled = false
  description                      = var.alert_rule_name
  display_name                     = var.alert_rule_name
  enabled                          = true
  skip_query_validation            = false
  action {
    action_groups = [var.logic_apps_action_group_id]
    custom_properties = {
      key  = "value"
      key2 = "value2"
    }
  }

  tags = var.tags
}