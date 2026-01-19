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

# Virtual Network Module
module "vnet" {
  source = "./modules/networking/vnet"

  name                = local.use_naming_convention && var.vnet_name == null ? local.naming.vnet : var.vnet_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers

  tags = local.merged_tags
}

# Subnets Module
module "subnets" {
  source = "./modules/networking/subnet"

  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  subnets = local.use_naming_convention ? {
    for k, v in var.subnets : k => merge(v, {
      name = lookup(v, "name", null) != null ? v.name : "${var.project_name}-${var.environment}-${var.purpose}-${k}-sbn"
    })
  } : var.subnets

  tags = local.merged_tags
}

# Application Gateway Module
module "application_gateway" {
  count = var.application_gateway_enabled && var.application_gateway_config != null ? 1 : 0

  source = "./modules/networking/application-gateway"

  name                = local.use_naming_convention && var.application_gateway_name == null ? local.naming.application_gateway : var.application_gateway_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  subnet_id           = var.application_gateway_subnet_id != null ? module.subnets.subnet_ids[var.application_gateway_subnet_id] : null
  sku_name            = var.application_gateway_config.sku_name
  sku_tier            = var.application_gateway_config.sku_tier
  capacity            = var.application_gateway_config.capacity
  public_ip_enabled   = lookup(var.application_gateway_config, "public_ip_enabled", true)
  public_ip_name      = lookup(var.application_gateway_config, "public_ip_name", null)
  public_ip_allocation_method = lookup(var.application_gateway_config, "public_ip_allocation_method", "Static")
  public_ip_sku       = lookup(var.application_gateway_config, "public_ip_sku", "Standard")
  private_ip_address  = lookup(var.application_gateway_config, "private_ip_address", null)
  private_ip_address_allocation = lookup(var.application_gateway_config, "private_ip_address_allocation", "Static")
  frontend_ports      = var.application_gateway_config.frontend_ports
  backend_address_pools = var.application_gateway_config.backend_address_pools
  backend_http_settings = var.application_gateway_config.backend_http_settings
  http_listeners      = var.application_gateway_config.http_listeners
  request_routing_rules = var.application_gateway_config.request_routing_rules
  ssl_certificates    = lookup(var.application_gateway_config, "ssl_certificates", [])
  probes              = lookup(var.application_gateway_config, "probes", [])
  container_app_fqdns = module.compute.container_app_fqdns
  auto_connect_container_apps = lookup(var.application_gateway_config, "auto_connect_container_apps", true)

  tags = local.merged_tags

  depends_on = [module.subnets]
}

# Compute Module (Container Apps + Virtual Machines)
module "compute" {
  source = "./modules/compute/container-apps"

  resource_group_name            = module.rg.name
  location                       = module.rg.location
  container_app_environment_name = local.use_naming_convention && var.container_app_environment_name == null ? local.naming.container_app_environment : var.container_app_environment_name
  infrastructure_subnet_id       = var.container_apps_subnet_id != null ? module.subnets.subnet_ids[var.container_apps_subnet_id] : null
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_workspace_name   = var.log_analytics_workspace_name
  log_analytics_workspace_suffix = var.log_analytics_workspace_suffix
  log_analytics_workspace_sku    = var.log_analytics_workspace_sku
  log_analytics_retention_days   = var.log_analytics_retention_days
  container_apps                 = local.container_apps
  virtual_machines                = var.virtual_machines != null ? {
    for k, v in var.virtual_machines : k => merge(v, {
      subnet_id = module.subnets.subnet_ids[v.subnet_id]
    })
  } : {}
  
  # Key Vault integration
  key_vault_id = local.key_vault_id
  key_vault_secrets = local.key_vault_id != null ? merge(
    var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? module.acr[0].key_vault_secret_ids : {},
    var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].key_vault_secret_ids : {},
    var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? module.postgres[0].key_vault_secret_ids : {},
    var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].key_vault_secret_ids : {},
    var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].key_vault_secret_ids : {}
  ) : {}
  
  tags = local.merged_tags
  
  depends_on = [module.keyvault]
}

# RBAC role assignment for Container Apps to access Key Vault
# Note: This is handled within the Container Apps module to avoid circular dependencies

# Data source for current client config (for tenant_id)
data "azurerm_client_config" "current" {}

# Key Vault Module (must be created first for other services)
module "keyvault" {
  count = var.key_vault_enabled && var.key_vault_config != null ? 1 : 0

  source = "./modules/data/keyvault"

  name                = local.use_naming_convention && var.key_vault_name == null ? local.naming.key_vault : var.key_vault_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  tenant_id           = lookup(var.key_vault_config, "tenant_id", null) != null ? var.key_vault_config.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name            = lookup(var.key_vault_config, "sku_name", "standard")
  enabled_for_deployment          = lookup(var.key_vault_config, "enabled_for_deployment", false)
  enabled_for_disk_encryption     = lookup(var.key_vault_config, "enabled_for_disk_encryption", false)
  enabled_for_template_deployment = lookup(var.key_vault_config, "enabled_for_template_deployment", false)
  rbac_authorization_enabled       = lookup(var.key_vault_config, "rbac_authorization_enabled", true)
  public_network_access_enabled    = lookup(var.key_vault_config, "public_network_access_enabled", false)
  purge_protection_enabled         = lookup(var.key_vault_config, "purge_protection_enabled", false)
  soft_delete_retention_days      = lookup(var.key_vault_config, "soft_delete_retention_days", 90)
  network_acls                     = lookup(var.key_vault_config, "network_acls", null)
  contacts                         = lookup(var.key_vault_config, "contacts", null)
  access_policies                  = lookup(var.key_vault_config, "access_policies", {})

  tags = local.merged_tags
}

# Key Vault ID for other modules
locals {
  key_vault_id = var.key_vault_enabled && var.key_vault_config != null && length(module.keyvault) > 0 ? module.keyvault[0].id : null
}

# Container Registry Module
module "acr" {
  count = var.container_registry_enabled && var.container_registry_config != null ? 1 : 0

  source = "./modules/data/acr"

  name                = local.use_naming_convention && var.container_registry_name == null ? local.naming.container_registry : var.container_registry_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  sku                 = lookup(var.container_registry_config, "sku", "Basic")
  admin_enabled       = lookup(var.container_registry_config, "admin_enabled", false)
  public_network_access_enabled = lookup(var.container_registry_config, "public_network_access_enabled", false)
  georeplications     = lookup(var.container_registry_config, "georeplications", null)
  network_rule_set    = lookup(var.container_registry_config, "network_rule_set", null)
  retention_policy    = lookup(var.container_registry_config, "retention_policy", null)
  trust_policy        = lookup(var.container_registry_config, "trust_policy", null)
  encryption          = lookup(var.container_registry_config, "encryption", null)
  identity_type       = lookup(var.container_registry_config, "identity_type", "SystemAssigned")
  identity_ids        = lookup(var.container_registry_config, "identity_ids", [])
  key_vault_id        = local.key_vault_id

  tags = local.merged_tags
}

# Cosmos DB Module
module "cosmos" {
  count = var.cosmos_db_enabled && var.cosmos_db_config != null ? 1 : 0

  source = "./modules/data/cosmos"

  name                = local.use_naming_convention && var.cosmos_db_name == null ? local.naming.cosmos_db : var.cosmos_db_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  offer_type          = lookup(var.cosmos_db_config, "offer_type", "Standard")
  kind                = lookup(var.cosmos_db_config, "kind", "GlobalDocumentDB")
  consistency_level   = lookup(var.cosmos_db_config, "consistency_level", "Session")
  max_interval_in_seconds = lookup(var.cosmos_db_config, "max_interval_in_seconds", 5)
  max_staleness_prefix   = lookup(var.cosmos_db_config, "max_staleness_prefix", 100)
  capabilities            = lookup(var.cosmos_db_config, "capabilities", null)
  geo_locations           = var.cosmos_db_config.geo_locations
  backup                  = lookup(var.cosmos_db_config, "backup", null)
  cors_rule               = lookup(var.cosmos_db_config, "cors_rule", null)
  is_virtual_network_filter_enabled = lookup(var.cosmos_db_config, "is_virtual_network_filter_enabled", false)
  virtual_network_rules              = lookup(var.cosmos_db_config, "virtual_network_rules", [])
  ip_range_filter                   = lookup(var.cosmos_db_config, "ip_range_filter", null) != null ? (can(tolist(var.cosmos_db_config.ip_range_filter)) ? var.cosmos_db_config.ip_range_filter : [var.cosmos_db_config.ip_range_filter]) : null
  public_network_access_enabled     = lookup(var.cosmos_db_config, "public_network_access_enabled", false)
  access_key_metadata_writes_enabled = lookup(var.cosmos_db_config, "access_key_metadata_writes_enabled", true)
  local_authentication_disabled      = lookup(var.cosmos_db_config, "local_authentication_disabled", false)
  identity_type                     = lookup(var.cosmos_db_config, "identity_type", "SystemAssigned")
  identity_ids                      = lookup(var.cosmos_db_config, "identity_ids", [])
  databases                         = lookup(var.cosmos_db_config, "databases", {})
  containers                        = lookup(var.cosmos_db_config, "containers", {})
  key_vault_id                      = local.key_vault_id

  tags = local.merged_tags
}

# PostgreSQL Module
module "postgres" {
  count = var.postgresql_enabled && var.postgresql_config != null ? 1 : 0

  source = "./modules/data/postgres"

  name                = local.use_naming_convention && var.postgresql_name == null ? local.naming.postgresql : var.postgresql_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  server_version      = lookup(var.postgresql_config, "server_version", "14")
  administrator_login    = var.postgresql_config.administrator_login
  administrator_password  = var.postgresql_config.administrator_password
  sku_name             = lookup(var.postgresql_config, "sku_name", "B_Standard_B1ms")
  storage_mb           = lookup(var.postgresql_config, "storage_mb", 32768)
  backup_retention_days = lookup(var.postgresql_config, "backup_retention_days", 7)
  geo_redundant_backup_enabled = lookup(var.postgresql_config, "geo_redundant_backup_enabled", false)
  public_network_access_enabled = lookup(var.postgresql_config, "public_network_access_enabled", false)
  maintenance_window            = lookup(var.postgresql_config, "maintenance_window", null)
  high_availability             = lookup(var.postgresql_config, "high_availability", null)
  identity_type                 = lookup(var.postgresql_config, "identity_type", null)
  identity_ids                  = lookup(var.postgresql_config, "identity_ids", [])
  firewall_rules                = lookup(var.postgresql_config, "firewall_rules", {})
  databases                     = lookup(var.postgresql_config, "databases", {})
  server_configurations          = lookup(var.postgresql_config, "server_configurations", {})
  key_vault_id                  = local.key_vault_id

  tags = local.merged_tags
}

# AI Foundry Module
module "foundry" {
  count = var.foundry_enabled && var.foundry_config != null ? 1 : 0

  source = "./modules/services/foundry"

  name                = local.use_naming_convention && var.foundry_name == null ? local.naming.foundry : var.foundry_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  storage_account_id         = lookup(var.foundry_config, "storage_account_id", null)
  storage_account_name       = lookup(var.foundry_config, "storage_account_name", null)
  storage_account_tier       = lookup(var.foundry_config, "storage_account_tier", "Standard")
  storage_account_replication_type = lookup(var.foundry_config, "storage_account_replication_type", "LRS")
  storage_account_public_network_access_enabled = lookup(var.foundry_config, "storage_account_public_network_access_enabled", false)
  key_vault_id               = local.key_vault_id
  public_network_access_enabled = lookup(var.foundry_config, "public_network_access_enabled", false)
  identity_type              = lookup(var.foundry_config, "identity_type", "SystemAssigned")
  identity_ids               = lookup(var.foundry_config, "identity_ids", [])
  create_project             = lookup(var.foundry_config, "create_project", false)
  project_name               = lookup(var.foundry_config, "project_name", null)
  project_identity_type      = lookup(var.foundry_config, "project_identity_type", null)
  project_identity_ids       = lookup(var.foundry_config, "project_identity_ids", [])
  deployments                = lookup(var.foundry_config, "deployments", {})

  tags = local.merged_tags

  depends_on = [module.keyvault]
}

# OpenAI Module
module "openai" {
  count = var.openai_enabled && var.openai_config != null ? 1 : 0

  source = "./modules/services/openai"

  name                = local.use_naming_convention && var.openai_name == null ? local.naming.openai : var.openai_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  sku_name            = lookup(var.openai_config, "sku_name", "S0")
  public_network_access_enabled = lookup(var.openai_config, "public_network_access_enabled", false)
  identity_type                 = lookup(var.openai_config, "identity_type", "SystemAssigned")
  identity_ids                  = lookup(var.openai_config, "identity_ids", [])
  deployments                   = lookup(var.openai_config, "deployments", {})
  key_vault_id                  = local.key_vault_id

  tags = local.merged_tags
}

# Networking PE Module (Private Endpoints + Private DNS Zones)
module "networking_pe" {
  count = var.private_endpoints_enabled ? 1 : 0

  source = "./modules/networking/pe"

  resource_group_name = module.rg.name
  location            = module.rg.location
  vnet_id             = module.vnet.id

  # Private DNS Zones
  private_dns_zones = {
    keyvault = {
      name               = "privatelink.vaultcore.azure.net"
      virtual_network_ids = [module.vnet.id]
      registration_enabled = false
    }
    cosmos = {
      name               = "privatelink.documents.azure.com"
      virtual_network_ids = [module.vnet.id]
      registration_enabled = false
    }
    postgres = {
      name               = "privatelink.postgres.database.azure.com"
      virtual_network_ids = [module.vnet.id]
      registration_enabled = false
    }
    acr = {
      name               = "privatelink.azurecr.io"
      virtual_network_ids = [module.vnet.id]
      registration_enabled = false
    }
  }

  # Private Endpoints
  private_endpoints = {
    for k, v in {
      keyvault = var.key_vault_enabled && var.key_vault_config != null && length(module.keyvault) > 0 ? {
        name                          = "${local.use_naming_convention && var.key_vault_name == null ? local.naming.key_vault : var.key_vault_name}-pe"
        subnet_id                     = var.private_endpoint_subnet_id != null ? module.subnets.subnet_ids[var.private_endpoint_subnet_id] : module.subnets.subnet_ids["pe"]
        private_connection_resource_id = module.keyvault[0].id
        subresource_names              = ["vault"]
        private_dns_zone_key           = "keyvault"
      } : null
      cosmos = var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? {
        name                          = "${local.use_naming_convention && var.cosmos_db_name == null ? local.naming.cosmos_db : var.cosmos_db_name}-pe"
        subnet_id                     = var.private_endpoint_subnet_id != null ? module.subnets.subnet_ids[var.private_endpoint_subnet_id] : module.subnets.subnet_ids["pe"]
        private_connection_resource_id = module.cosmos[0].id
        subresource_names              = ["Sql"]
        private_dns_zone_key           = "cosmos"
      } : null
      postgres = var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? {
        name                          = "${local.use_naming_convention && var.postgresql_name == null ? local.naming.postgresql : var.postgresql_name}-pe"
        subnet_id                     = var.private_endpoint_subnet_id != null ? module.subnets.subnet_ids[var.private_endpoint_subnet_id] : module.subnets.subnet_ids["pe"]
        private_connection_resource_id = module.postgres[0].id
        subresource_names              = ["postgresqlServer"]
        private_dns_zone_key           = "postgres"
      } : null
      acr = var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? {
        name                          = "${local.use_naming_convention && var.container_registry_name == null ? local.naming.container_registry : var.container_registry_name}-pe"
        subnet_id                     = var.private_endpoint_subnet_id != null ? module.subnets.subnet_ids[var.private_endpoint_subnet_id] : module.subnets.subnet_ids["pe"]
        private_connection_resource_id = module.acr[0].id
        subresource_names              = ["registry"]
        private_dns_zone_key           = "acr"
      } : null
    } : k => v if v != null
  }

  tags = local.merged_tags

  depends_on = [module.keyvault, module.acr, module.cosmos, module.postgres, module.foundry, module.openai]
}
