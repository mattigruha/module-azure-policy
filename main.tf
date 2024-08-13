resource "azurerm_subscription_policy_assignment" "assignment" {
  name                 = lower(var.policy_assignment_name)
  policy_definition_id = var.policy_definition_id
  description          = var.policy_assignment_description
  display_name         = var.display_name
  subscription_id      = var.subscription_id
  not_scopes           = var.not_scopes
  location             = var.location

  parameters = var.parameters_content

  non_compliance_message {
    content = var.non_compliance_message
  }

  identity {
    type         = var.identity_type
    identity_ids = [var.identity_id]
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    read   = var.timeouts.read
    delete = var.timeouts.delete
  }
}

resource "azurerm_subscription_policy_remediation" "remediation" {
  count = var.create_remediation_task ? 1 : 0

  name                 = "${lower(var.policy_assignment_name)}-remediation"
  subscription_id      = var.subscription_id
  policy_assignment_id = azurerm_subscription_policy_assignment.assignment.id
}
