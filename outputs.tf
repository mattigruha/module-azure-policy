output "policy_assignment_id" {
  description = "The ID of the policy assignment"
  value       = azurerm_subscription_policy_assignment.assignment.id
}
