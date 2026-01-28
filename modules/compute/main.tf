# Container Apps Module
module "container_apps" {
  source = "./container-apps"

  resource_group_name            = var.resource_group_name
  location                       = var.location
  container_app_environment_name = var.container_app_environment_name
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_workspace_name   = var.log_analytics_workspace_name
  log_analytics_workspace_suffix = var.log_analytics_workspace_suffix
  log_analytics_workspace_sku    = var.log_analytics_workspace_sku
  log_analytics_retention_days   = var.log_analytics_retention_days
  container_apps                 = var.container_apps

  # Key Vault integration
  key_vault_id                = var.key_vault_id
  key_vault_secrets           = var.key_vault_secrets
  container_app_identity_type = var.container_app_identity_type

  tags = var.tags
}

# Virtual Machines Module
module "virtual_machines" {
  source = "./virtual-machines"
  count  = var.virtual_machines != null && length(var.virtual_machines) > 0 ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_machines    = var.virtual_machines
  tags                = var.tags
}
