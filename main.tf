##################
# Security Center
##################

# Definitions (Name and Display Name)
locals {
  security_center_policies = {
    auto_enroll_subscriptions                              = "(PAC) Enable Azure Security Center on Subcriptions"
    auto_provision_log_analytics_agent_custom_workspace    = "(PAC) Enable Security Center's auto provisioning of the Log Analytics agent on your subscriptions with custom workspace"
    auto_set_contact_details                               = "(PAC) Automatically set the security contact email address and phone number should they be blank on the subscription"
    export_asc_alerts_and_recommendations_to_eventhub      = "(PAC) Export to Event Hub for Azure Security Center alerts and recommendations"
    export_asc_alerts_and_recommendations_to_log_analytics = "(PAC) Export to Log Analytics Workspace for Azure Security Center alerts and recommendations"
    # polices for Arc servers
    deploy_linux_log_analytics_agents                      = "(PAC) Deploy Linux Log Analytics agents - 9d2b61b4-1d14-4a63-be30-d4498e7ad2cf"
    deploy_windows_log_analytics_agents                    = "(PAC) Deploy Windows Log Analytics agents - 69af7d4a-7b18-4044-93a9-2651498ef203"
    deploy_linux_dependency_agents                         = "(PAC) Deploy Linux Dependency Agents - deacecc0-9f84-44d2-bb82-46f32d766d43"
    deploy_windows_dependency_agents                       = "(PAC) Deploy Windows Dependency Agents - 91cb9edd-cd92-4d2f-b2f2-bdd8d065a3d4"
    deploy_mde_for_endpoint_agent_on_linux                 = "(PAC) Deploy Microsoft Defender for Endpoint agent on Linux hybrid machines"
    deploy_mde_for_endpoint_agent_on_windows               = "(PAC) Deploy Microsoft Defender for Endpoint agent on Windows ARC machines"
  }
}

module configure_asc {
  source                = "./modules/definition"
  for_each              = local.security_center_policies
  policy_name           = each.key
  display_name          = title(replace(each.value, "_", " "))
  policy_description    = title(replace(each.value, "_", " "))
  policy_category       = "Security Center"
  management_group_id = data.azurerm_management_group.org.id
}

# Initiative
module configure_asc_initiative {
  source                  = "./modules/initiative"
  initiative_name         = "configure_asc_initiative"
  initiative_display_name = "[Security]: Configure Azure Security Center"
  initiative_description  = "Deploys and configures Azure Security Center settings and defines exports"
  initiative_category     = "Security Center"
  management_group_id   = data.azurerm_management_group.org.id

  member_definitions = [
    module.configure_asc["auto_enroll_subscriptions"].definition,
    module.configure_asc["auto_provision_log_analytics_agent_custom_workspace"].definition,
    module.configure_asc["auto_set_contact_details"].definition,
    module.configure_asc["export_asc_alerts_and_recommendations_to_eventhub"].definition,
    module.configure_asc["export_asc_alerts_and_recommendations_to_log_analytics"].definition,
    module.configure_asc["deploy_mde_for_endpoint_agent_on_linux"].definition,
    module.configure_asc["deploy_mde_for_endpoint_agent_on_windows"].definition
        
    
  ]

  # member_definitions = [
  #   module.configure_asc["auto_enroll_subscriptions"].definition,
  #   module.configure_asc["auto_provision_log_analytics_agent_custom_workspace"].definition,
  #   module.configure_asc["auto_set_contact_details"].definition,
  #   module.configure_asc["export_asc_alerts_and_recommendations_to_eventhub"].definition,
  #   module.configure_asc["export_asc_alerts_and_recommendations_to_log_analytics"].definition,
  #   module.configure_asc["deploy_linux_log_analytics_agents"].definition,
  #   module.configure_asc["deploy_windows_log_analytics_agents"].definition,
  #   module.configure_asc["deploy_mde_for_endpoint_agent_on_linux"].definition
    
  # ]
}

# Assignment
module org_mg_configure_asc_initiative {
  source              = "./modules/set_assignment"
  initiative          = module.configure_asc_initiative.initiative
  assignment_scope    = data.azurerm_management_group.org.id
  assignment_effect   = "DeployIfNotExists"
  skip_remediation    = var.skip_remediation
  skip_role_assignment = var.skip_role_assignment
  role_definition_ids  = module.configure_asc_initiative.role_definition_ids

  assignment_parameters = {
    workspaceId           = local.dummy_resource_ids.azurerm_log_analytics_workspace
    eventHubDetails       = local.dummy_resource_ids.azurerm_eventhub_namespace_authorization_rule
    securityContactsEmail = "admin@clientcloud.com"
    securityContactsPhone = "07970121121"
  }
}