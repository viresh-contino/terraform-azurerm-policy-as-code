##################
# Guest Configuration
##################

# Onboarding Prerequisites
module "team_a_mg_guest_config_prereqs_initiative" {
  source              = "..//modules/set_assignment"
  initiative          = module.guest_config_prereqs_initiative.initiative
  assignment_scope    = data.azurerm_management_group.team_a.id
  skip_remediation    = var.skip_remediation
  role_definition_ids = module.guest_config_prereqs_initiative.role_definition_ids
  assignment_parameters = {
    listOfImageIdToInclude_windows = []
    listOfImageIdToInclude_linux   = []
  }
}

# Custom Config Packages
module "team_a_mg_custom_guest_configs_initiative" {
  source              = "..//modules/set_assignment"
  initiative          = module.custom_guest_configs_initiative.initiative
  assignment_scope    = data.azurerm_management_group.team_a.id
  skip_remediation    = var.skip_remediation
  role_definition_ids = module.custom_guest_configs_initiative.role_definition_ids
  assignment_parameters = {
    IncludeArcMachines = "False"
  }
}
