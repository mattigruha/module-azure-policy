# Description
Terraform Module for deploying built-in Azure policies. With this module you can assign policies on subscription-level and if needed (optional) create remediations tasks. These remediation tasks will be created for every single subscription policy assignment. As a prerequisite you will need a resource group and an user assigned identity outside of this module, with the permissions needed for the remediation (in this case contributor permissions).

When using this module, you'll need to have a good look at the needed parameters (json) input that is required for the policy to work properly. This can be done easily by deploying a policy manually in the Azure portal and then viewing the definition in json, when you're doing this it's also possible to have a look at the necessary parameters.

## Requirements

| Name | Version |
|------|---------|
| [terraform](#requirement\_terraform) | >= 1.0.0 |
| [azurerm](#requirement\_azurerm) | >= 3.0.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| [azurerm](#provider\_azurerm) | 3.93.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subscription_policy_assignment.assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) | resource |
| [azurerm_subscription_policy_remediation.remediation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_remediation) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| [create\_remediation\_task](#input\_create\_remediation\_task) | If the remediation task for the policy assignment needs to be created. Defaults to true and uses the policy assignment name as input for the remediation name. | `bool` | `true` | no |
| [display\_name](#input\_display\_name) | Display name of the policy assignment | `string` | n/a | yes |
| [identity\_id](#input\_identity\_id) | The ID of the User Assigned Identity | `string` | n/a | yes |
| [identity\_type](#input\_identity\_type) | The type of managed identity assigned to the policy assignment | `string` | `"UserAssigned"` | no |
| [location](#input\_location) | Location of the policy assignment | `string` | `"West Europe"` | no |
| [non\_compliance\_message](#input\_non\_compliance\_message) | The message that will be shown when the policy is not compliant | `string` | n/a | yes |
| [not\_scopes](#input\_not\_scopes) | A list of scopes that are excluded from the policy assignment | `list(string)` | `[]` | no |
| [parameters\_content](#input\_parameters\_content) | Parameters content for the policy assignment | `string` | n/a | yes |
| [policy\_assignment\_description](#input\_policy\_assignment\_description) | Description of the policy assignment | `string` | n/a | yes |
| [policy\_assignment\_name](#input\_policy\_assignment\_name) | Name of the policy assignment | `string` | n/a | yes |
| [policy\_definition\_id](#input\_policy\_definition\_id) | ID of the policy definition | `string` | n/a | yes |
| [subscription\_id](#input\_subscription\_id) | ID of the subscription where the policy will be assigned | `string` | n/a | yes |
| [timeouts](#input\_timeouts) | Map of timeouts for creating, updating, reading, and deleting operations | ```object({ create = string update = string read = string delete = string })``` | ```{ "create": "30m", "delete": "30m", "read": "5m", "update": "30m" }``` | no |

## Outputs

| Name | Description |
|------|-------------|
| [policy\_assignment\_id](#output\_policy\_assignment\_id) | The ID of the policy assignment |


####################################################################################################
# Example usage of the module for inheriting multiple tags from the resource group to the resources
####################################################################################################
```hcl
locals {
  required_tag_keys = toset(["Application", "Environment", "Project", "Owner"])
}

module "tag_inheritance_policy" {
  for_each = local.required_tag_keys

  source = "../.." # Change to the correct source path

  policy_assignment_name        = "${var.environment}-test-inherit-tag-${each.key}"
  display_name                  = "Inherit tag ${each.key} from the resource group to the resources"
  location                      = "West Europe"
  subscription_id               = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  policy_definition_id          = "/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070"
  policy_assignment_description = "Inherit tag ${each.key} from the resource group to the resources"
  non_compliance_message        = "The resource is missing the tag ${each.key}"
  parameters_content = jsonencode({
    "tagName" : {
      "value" = each.value
    }
  })

  identity_type = "UserAssigned"
  identity_id   = azurerm_user_assigned_identity.id.id
  not_scopes    = []

  create_remediation_task = true

  timeouts = {
    create = "30m"
    update = "30m"
    read   = "5m"
    delete = "30m"
  }
}

##############################################################################################################################################
# Example usage of the module for configuring automatic updates assessment for different machine types (Linux and Windows VM's & Arc machines)
##############################################################################################################################################

locals {
  customer_tla = "sbx"

  missing_updates_policies = {
    updates_arc_windows = {
      name                 = "${local.customer_tla}-missing-updates-arcmachines-windows"
      display_name         = "${upper(local.customer_tla)} - ${var.environment} - Periodic updates assessment for Arc Windows machines"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/bfea026e-043f-4ff4-9d1b-bf301ca7ff46"
      parameters = {
        assessmentMode = {
          value = "AutomaticByPlatform"
        },
        osType = {
          value = "Windows"
        },
        locations = {
          value = ["West Europe"]
        },
        tagOperator = {
          value = "Any"
        }
      }
    },

    updates_arc_linux = {
      name                 = "${local.customer_tla}-missing-updates-arcmachines-linux"
      display_name         = "${upper(local.customer_tla)} - ${var.environment} - Periodic updates assessment for Arc Linux machines"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/bfea026e-043f-4ff4-9d1b-bf301ca7ff46"
      parameters = {
        assessmentMode = {
          value = "AutomaticByPlatform"
        },
        osType = {
          value = "Linux"
        },
        locations = {
          value = ["West Europe"]
        },
        tagOperator = {
          value = "Any"
        }
      }
    },

    updates_vm_windows = {
      name                 = "${local.customer_tla}-missing-updates-vm-windows"
      display_name         = "${upper(local.customer_tla)} - ${var.environment} - Periodic updates assessment for Windows VM's"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/59efceea-0c96-497e-a4a1-4eb2290dac15"
      parameters = {
        assessmentMode = {
          value = "AutomaticByPlatform"
        },
        osType = {
          value = "Windows"
        },
        locations = {
          value = ["West Europe"]
        },
        tagOperator = {
          value = "Any"
        }
      }
    },

    updates_vm_linux = {
      name                 = "${local.customer_tla}-missing-updates-vm-linux"
      display_name         = "${upper(local.customer_tla)} - ${var.environment} - Periodic updates assessment for Linux VM's"
      policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/59efceea-0c96-497e-a4a1-4eb2290dac15"
      parameters = {
        assessmentMode = {
          value = "AutomaticByPlatform"
        },
        osType = {
          value = "Linux"
        },
        locations = {
          value = ["West Europe"]
        },
        tagOperator = {
          value = "Any"
        }
      }
    }
  }
}

module "missing_update_management_policy" {
  for_each = local.missing_updates_policies

  source = "../.." # Change to the correct source path

  policy_assignment_name        = each.value.name
  display_name                  = each.value.display_name
  location                      = "West Europe"
  subscription_id               = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  policy_definition_id          = each.value.policy_definition_id
  policy_assignment_description = "Checks if the machine has periodic updates assessment enabled."
  non_compliance_message        = "Your machine doesn't have periodic updates assessment enabled."
  parameters_content            = jsonencode(each.value.parameters)

  identity_type = "UserAssigned"
  identity_id   = azurerm_user_assigned_identity.id.id
  not_scopes    = []

  create_remediation_task = true

  timeouts = {
    create = "30m"
    update = "30m"
    read   = "5m"
    delete = "30m"
  }
}
