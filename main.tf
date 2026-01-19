provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

# Resource Group Module
module "rg" {
  source = "./modules/foundation/rg"

  name     = local.use_naming_convention && var.resource_group_name == null ? local.naming.resource_group : var.resource_group_name
  location = var.location
  tags     = local.merged_tags
}

# Networking Core Module (VNet + Subnets + Application Gateway)
module "networking_core" {
  source = "./modules/networking/core"

  name                = local.use_naming_convention && var.vnet_name == null ? local.naming.vnet : var.vnet_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
  subnets = local.use_naming_convention ? {
    for k, v in var.subnets : k => merge(v, {
      name = lookup(v, "name", null) != null ? v.name : "${var.project_name}-${var.environment}-${var.purpose}-${k}-sbn"
    })
  } : var.subnets

  # Application Gateway configuration
  application_gateway_enabled   = var.application_gateway_enabled
  application_gateway_name      = local.use_naming_convention && var.application_gateway_name == null ? local.naming.application_gateway : var.application_gateway_name
  application_gateway_subnet_id = var.application_gateway_subnet_id
  application_gateway_config    = var.application_gateway_config
  container_app_fqdns           = module.compute.container_app_fqdns

  tags = local.merged_tags
}

# Compute Module (Container Apps + Virtual Machines)
module "compute" {
  source = "./modules/compute/container-apps"

  resource_group_name            = module.rg.name
  location                       = module.rg.location
  container_app_environment_name = local.use_naming_convention && var.container_app_environment_name == null ? local.naming.container_app_environment : var.container_app_environment_name
  infrastructure_subnet_id       = var.container_apps_subnet_id != null ? module.networking_core.subnet_ids[var.container_apps_subnet_id] : null
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_workspace_name   = var.log_analytics_workspace_name
  log_analytics_workspace_suffix = var.log_analytics_workspace_suffix
  log_analytics_workspace_sku    = var.log_analytics_workspace_sku
  log_analytics_retention_days   = var.log_analytics_retention_days
  container_apps                 = local.container_apps
  virtual_machines                = var.virtual_machines != null ? {
    for k, v in var.virtual_machines : k => merge(v, {
      subnet_id = module.networking_core.subnet_ids[v.subnet_id]
    })
  } : {}
  
  # Key Vault integration
  key_vault_id = module.infra.key_vault_id
  key_vault_secrets = module.infra.key_vault_id != null ? {
    for k, v in module.infra.key_vault_secret_ids : k => v
    if v != null
  } : {}
  
  tags = local.merged_tags
  
  depends_on = [module.infra]
}

# RBAC role assignment for Container Apps to access Key Vault
# Note: This is handled within the Container Apps module to avoid circular dependencies

# Infrastructure Module (All PaaS Services)
module "infra" {
  source = "./modules/services/infra"

  resource_group_name = module.rg.name
  location            = module.rg.location

  # Container Registry
  container_registry_enabled = var.container_registry_enabled
  container_registry_name    = local.use_naming_convention && var.container_registry_name == null ? local.naming.container_registry : var.container_registry_name
  container_registry_config  = var.container_registry_config

  # Key Vault
  key_vault_enabled = var.key_vault_enabled
  key_vault_name    = local.use_naming_convention && var.key_vault_name == null ? local.naming.key_vault : var.key_vault_name
  key_vault_config  = var.key_vault_config

  # Cosmos DB
  cosmos_db_enabled = var.cosmos_db_enabled
  cosmos_db_name    = local.use_naming_convention && var.cosmos_db_name == null ? local.naming.cosmos_db : var.cosmos_db_name
  cosmos_db_config  = var.cosmos_db_config

  # PostgreSQL
  postgresql_enabled = var.postgresql_enabled
  postgresql_name    = local.use_naming_convention && var.postgresql_name == null ? local.naming.postgresql : var.postgresql_name
  postgresql_config  = var.postgresql_config

  # AI Foundry
  foundry_enabled = var.foundry_enabled
  foundry_name    = local.use_naming_convention && var.foundry_name == null ? local.naming.foundry : var.foundry_name
  foundry_config  = var.foundry_config

  # OpenAI
  openai_enabled = var.openai_enabled
  openai_name    = local.use_naming_convention && var.openai_name == null ? local.naming.openai : var.openai_name
  openai_config  = var.openai_config

  tags = local.merged_tags
}

# Networking PE Module (Private Endpoints + Private DNS Zones)
module "networking_pe" {
  count = var.private_endpoints_enabled ? 1 : 0

  source = "./modules/networking/pe"

  resource_group_name = module.rg.name
  location            = module.rg.location
  vnet_id             = module.networking_core.vnet_id

  # Private DNS Zones
  private_dns_zones = {
    keyvault = {
      name               = "privatelink.vaultcore.azure.net"
      virtual_network_ids = [module.networking_core.vnet_id]
      registration_enabled = false
    }
    cosmos = {
      name               = "privatelink.documents.azure.com"
      virtual_network_ids = [module.networking_core.vnet_id]
      registration_enabled = false
    }
    postgres = {
      name               = "privatelink.postgres.database.azure.com"
      virtual_network_ids = [module.networking_core.vnet_id]
      registration_enabled = false
    }
    acr = {
      name               = "privatelink.azurecr.io"
      virtual_network_ids = [module.networking_core.vnet_id]
      registration_enabled = false
    }
  }

  # Private Endpoints
  private_endpoints = {
    for k, v in {
      keyvault = var.key_vault_enabled && var.key_vault_config != null ? {
        name                          = "${local.use_naming_convention && var.key_vault_name == null ? local.naming.key_vault : var.key_vault_name}-pe"
        subnet_id                     = var.private_endpoint_subnet_id != null ? module.networking_core.subnet_ids[var.private_endpoint_subnet_id] : module.networking_core.subnet_ids["pe"]
        private_connection_resource_id = module.infra.key_vault_id
        subresource_names              = ["vault"]
        private_dns_zone_key           = "keyvault"
      } : null
      cosmos = var.cosmos_db_enabled && var.cosmos_db_config != null ? {
        name                          = "${local.use_naming_convention && var.cosmos_db_name == null ? local.naming.cosmos_db : var.cosmos_db_name}-pe"
        subnet_id                     = var.private_endpoint_subnet_id != null ? module.networking_core.subnet_ids[var.private_endpoint_subnet_id] : module.networking_core.subnet_ids["pe"]
        private_connection_resource_id = module.infra.cosmos_db_id
        subresource_names              = ["Sql"]
        private_dns_zone_key           = "cosmos"
      } : null
      postgres = var.postgresql_enabled && var.postgresql_config != null ? {
        name                          = "${local.use_naming_convention && var.postgresql_name == null ? local.naming.postgresql : var.postgresql_name}-pe"
        subnet_id                     = var.private_endpoint_subnet_id != null ? module.networking_core.subnet_ids[var.private_endpoint_subnet_id] : module.networking_core.subnet_ids["pe"]
        private_connection_resource_id = module.infra.postgresql_id
        subresource_names              = ["postgresqlServer"]
        private_dns_zone_key           = "postgres"
      } : null
      acr = var.container_registry_enabled && var.container_registry_config != null ? {
        name                          = "${local.use_naming_convention && var.container_registry_name == null ? local.naming.container_registry : var.container_registry_name}-pe"
        subnet_id                     = var.private_endpoint_subnet_id != null ? module.networking_core.subnet_ids[var.private_endpoint_subnet_id] : module.networking_core.subnet_ids["pe"]
        private_connection_resource_id = module.infra.container_registry_id
        subresource_names              = ["registry"]
        private_dns_zone_key           = "acr"
      } : null
    } : k => v if v != null
  }

  tags = local.merged_tags

  depends_on = [module.infra]
}
