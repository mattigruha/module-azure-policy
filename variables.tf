variable "policy_assignment_name" {
  description = "Name of the policy assignment"
  type        = string
}

variable "location" {
  description = "Location of the policy assignment"
  type        = string
  default     = "West Europe"
}

variable "subscription_id" {
  description = "ID of the subscription where the policy will be assigned"
  type        = string
}

variable "policy_definition_id" {
  description = "ID of the policy definition"
  type        = string
}

variable "policy_assignment_description" {
  description = "Description of the policy assignment"
  type        = string
}

variable "display_name" {
  description = "Display name of the policy assignment"
  type        = string
}

variable "parameters_content" {
  description = "Parameters content for the policy assignment"
  type        = string
}

variable "non_compliance_message" {
  description = "The message that will be shown when the policy is not compliant"
  type        = string
}

variable "identity_type" {
  description = "The type of managed identity assigned to the policy assignment"
  type        = string
  default     = "UserAssigned"
}

variable "identity_id" {
  description = "The ID of the User Assigned Identity"
  type        = string
}

variable "not_scopes" {
  description = "A list of scopes that are excluded from the policy assignment"
  type        = list(string)
  default     = []
}

variable "timeouts" {
  description = "Map of timeouts for creating, updating, reading, and deleting operations"
  type = object({
    create = string
    update = string
    read   = string
    delete = string
  })
  default = {
    create = "30m"
    update = "30m"
    read   = "5m"
    delete = "30m"
  }
}

variable "create_remediation_task" {
  description = "If the remediation task for the policy assignment needs to be created. Defaults to true and uses the policy assignment name as input for the remediation name."
  type        = bool
  default     = true
}
