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

# Networking Module (VNet, Subnets, Application Gateway, Private Endpoints)
module "networking" {
  source = "./modules/networking"

  resource_group_name = module.rg.name
  location            = module.rg.location
  vnet_name           = local.use_naming_convention && var.vnet_name == null ? local.naming.vnet : var.vnet_name
  vnet_address_space  = var.vnet_address_space
  dns_servers         = var.dns_servers
  subnets = local.use_naming_convention ? {
    for k, v in var.subnets : k => merge(v, {
      name = lookup(v, "name", null) != null ? v.name : "${var.project_name}-${var.environment}-${var.purpose}-${k}-sbn"
    })
  } : var.subnets
  application_gateway_enabled = var.application_gateway_enabled
  application_gateway_name   = local.use_naming_convention && var.application_gateway_name == null ? local.naming.application_gateway : var.application_gateway_name
  application_gateway_subnet_id = var.application_gateway_subnet_id
  application_gateway_config = var.application_gateway_config
  container_app_fqdns = module.compute.container_app_fqdns
  private_endpoints_enabled = var.private_endpoints_enabled
  private_dns_zones = var.private_endpoints_enabled ? {
    keyvault = {
      name               = "privatelink.vaultcore.azure.net"
      virtual_network_ids = []  # Will be set to vnet_id inside the networking module
      registration_enabled = false
    }
    cosmos = {
      name               = "privatelink.documents.azure.com"
      virtual_network_ids = []
      registration_enabled = false
    }
    postgres = {
      name               = "privatelink.postgres.database.azure.com"
      virtual_network_ids = []
      registration_enabled = false
    }
    acr = {
      name               = "privatelink.azurecr.io"
      virtual_network_ids = []
      registration_enabled = false
    }
  } : {}
  private_endpoints = var.private_endpoints_enabled ? {
    keyvault = var.key_vault_enabled && var.key_vault_config != null ? {
      name                          = "${local.use_naming_convention && var.key_vault_name == null ? local.naming.key_vault : var.key_vault_name}-pe"
      subnet_id                     = var.private_endpoint_subnet_id != null ? module.networking.subnet_ids[var.private_endpoint_subnet_id] : module.networking.subnet_ids["pe"]
      private_connection_resource_id = module.data.key_vault_id
      subresource_names              = ["vault"]
      private_dns_zone_key           = "keyvault"
    } : null
    cosmos = var.cosmos_db_enabled && var.cosmos_db_config != null ? {
      name                          = "${local.use_naming_convention && var.cosmos_db_name == null ? local.naming.cosmos_db : var.cosmos_db_name}-pe"
      subnet_id                     = var.private_endpoint_subnet_id != null ? module.networking.subnet_ids[var.private_endpoint_subnet_id] : module.networking.subnet_ids["pe"]
      private_connection_resource_id = module.data.cosmos_db_id
      subresource_names              = ["Sql"]
      private_dns_zone_key           = "cosmos"
    } : null
    postgres = var.postgresql_enabled && var.postgresql_config != null ? {
      name                          = "${local.use_naming_convention && var.postgresql_name == null ? local.naming.postgresql : var.postgresql_name}-pe"
      subnet_id                     = var.private_endpoint_subnet_id != null ? module.networking.subnet_ids[var.private_endpoint_subnet_id] : module.networking.subnet_ids["pe"]
      private_connection_resource_id = module.data.postgresql_id
      subresource_names              = ["postgresqlServer"]
      private_dns_zone_key           = "postgres"
    } : null
    acr = var.container_registry_enabled && var.container_registry_config != null ? {
      name                          = "${local.use_naming_convention && var.container_registry_name == null ? local.naming.container_registry : var.container_registry_name}-pe"
      subnet_id                     = var.private_endpoint_subnet_id != null ? module.networking.subnet_ids[var.private_endpoint_subnet_id] : module.networking.subnet_ids["pe"]
      private_connection_resource_id = module.data.container_registry_id
      subresource_names              = ["registry"]
      private_dns_zone_key           = "acr"
    } : null
  } : {}

  tags = local.merged_tags
}

# Data Module (Key Vault, Container Registry, Cosmos DB, PostgreSQL)
module "data" {
  source = "./modules/data"

  resource_group_name = module.rg.name
  location            = module.rg.location
  key_vault_enabled  = var.key_vault_enabled
  key_vault_name     = local.use_naming_convention && var.key_vault_name == null ? local.naming.key_vault : var.key_vault_name
  key_vault_config   = var.key_vault_config
  container_registry_enabled = var.container_registry_enabled
  container_registry_name   = local.use_naming_convention && var.container_registry_name == null ? local.naming.container_registry : var.container_registry_name
  container_registry_config = var.container_registry_config
  cosmos_db_enabled = var.cosmos_db_enabled
  cosmos_db_name    = local.use_naming_convention && var.cosmos_db_name == null ? local.naming.cosmos_db : var.cosmos_db_name
  cosmos_db_config  = var.cosmos_db_config
  postgresql_enabled = var.postgresql_enabled
  postgresql_name    = local.use_naming_convention && var.postgresql_name == null ? local.naming.postgresql : var.postgresql_name
  postgresql_config  = var.postgresql_config

  tags = local.merged_tags
}

# Key Vault ID for other modules
locals {
  key_vault_id = module.data.key_vault_id
}

# Services Module (AI Foundry, OpenAI)
module "services" {
  source = "./modules/services"

  resource_group_name = module.rg.name
  location            = module.rg.location
  key_vault_id        = local.key_vault_id
  foundry_enabled     = var.foundry_enabled
  foundry_name        = local.use_naming_convention && var.foundry_name == null ? local.naming.foundry : var.foundry_name
  foundry_config      = var.foundry_config
  openai_enabled      = var.openai_enabled
  openai_name         = local.use_naming_convention && var.openai_name == null ? local.naming.openai : var.openai_name
  openai_config       = var.openai_config

  tags = local.merged_tags

  depends_on = [module.data]
}

# Afterjob Module - Key Vault Secrets (executed last, after all services are created)
# This module creates all Key Vault secrets after all services are created
module "afterjob" {
  source = "./modules/data/afterjob"

  key_vault_id     = local.key_vault_id
  key_vault_enabled = var.key_vault_enabled

  # ACR secrets (from data module)
  container_registry_enabled = var.container_registry_enabled
  acr_login_server   = module.data.container_registry_login_server
  acr_admin_username = module.data.container_registry_admin_username
  acr_admin_password = module.data.container_registry_admin_password

  # Cosmos DB secrets (from data module)
  cosmos_db_enabled = var.cosmos_db_enabled
  cosmosdb_endpoint     = module.data.cosmos_db_endpoint
  cosmosdb_primary_key  = module.data.cosmos_db_primary_key
  cosmosdb_secondary_key = module.data.cosmos_db_secondary_key

  # PostgreSQL secrets (from data module and variables)
  postgresql_enabled = var.postgresql_enabled
  postgresql_password  = var.postgresql_enabled && var.postgresql_config != null ? var.postgresql_config.administrator_password : null
  postgresql_fqdn      = module.data.postgresql_fqdn
  postgresql_admin_login = var.postgresql_enabled && var.postgresql_config != null ? var.postgresql_config.administrator_login : null

  # Foundry secrets (from services module)
  foundry_enabled  = var.foundry_enabled
  foundry_endpoint = module.services.foundry_endpoint

  # OpenAI secrets (from services module)
  openai_enabled      = var.openai_enabled
  openai_endpoint     = module.services.openai_endpoint
  openai_primary_key  = module.services.openai_primary_access_key
  openai_secondary_key = module.services.openai_secondary_access_key

  tags = local.merged_tags

  depends_on = [
    module.data,
    module.services
  ]
}

# Key Vault Secret IDs (from afterjob module)
locals {
  key_vault_secret_ids = module.afterjob.key_vault_secret_ids
}

# Compute Module (Container Apps + Virtual Machines)
module "compute" {
  source = "./modules/compute"

  resource_group_name            = module.rg.name
  location                       = module.rg.location
  container_app_environment_name = local.use_naming_convention && var.container_app_environment_name == null ? local.naming.container_app_environment : var.container_app_environment_name
  infrastructure_subnet_id        = var.container_apps_subnet_id != null ? module.networking.subnet_ids[var.container_apps_subnet_id] : null
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_workspace_name   = var.log_analytics_workspace_name
  log_analytics_workspace_suffix = var.log_analytics_workspace_suffix
  log_analytics_workspace_sku    = var.log_analytics_workspace_sku
  log_analytics_retention_days   = var.log_analytics_retention_days
  container_apps                 = local.container_apps
  virtual_machines                = var.virtual_machines != null ? {
    for k, v in var.virtual_machines : k => merge(v, {
      subnet_id = module.networking.subnet_ids[v.subnet_id]
    })
  } : {}
  
  # Key Vault integration
  key_vault_id      = local.key_vault_id
  key_vault_secrets = local.key_vault_secret_ids
  
  tags = local.merged_tags
  
  depends_on = [module.data]
}
