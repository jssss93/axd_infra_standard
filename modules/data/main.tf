# Data source for current client config (for tenant_id)
data "azurerm_client_config" "current" {}

# Key Vault Module (must be created first for other services)
module "keyvault" {
  count = var.key_vault_enabled && var.key_vault_config != null ? 1 : 0

  source = "./keyvault"

  name                            = var.key_vault_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tenant_id                       = try(var.key_vault_config.tenant_id, null) != null ? var.key_vault_config.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name                        = try(var.key_vault_config.sku_name, "standard")
  enabled_for_deployment          = try(var.key_vault_config.enabled_for_deployment, false)
  enabled_for_disk_encryption     = try(var.key_vault_config.enabled_for_disk_encryption, false)
  enabled_for_template_deployment = try(var.key_vault_config.enabled_for_template_deployment, false)
  rbac_authorization_enabled      = try(var.key_vault_config.rbac_authorization_enabled, true)
  public_network_access_enabled   = try(var.key_vault_config.public_network_access_enabled, null)
  purge_protection_enabled        = try(var.key_vault_config.purge_protection_enabled, false)
  soft_delete_retention_days      = try(var.key_vault_config.soft_delete_retention_days, 90)
  network_acls                    = try(var.key_vault_config.network_acls, null)
  contacts                        = try(var.key_vault_config.contacts, null)
  access_policies                 = try(var.key_vault_config.access_policies, {})

  tags = var.tags
}

# Key Vault ID for other modules
locals {
  key_vault_id = var.key_vault_enabled && var.key_vault_config != null && length(module.keyvault) > 0 ? module.keyvault[0].id : null
}

# Container Registry Module
module "acr" {
  count = var.container_registry_enabled && var.container_registry_config != null ? 1 : 0

  source = "./acr"

  name                          = var.container_registry_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = try(var.container_registry_config.sku, "Basic")
  admin_enabled                 = try(var.container_registry_config.admin_enabled, false)
  public_network_access_enabled = try(var.container_registry_config.public_network_access_enabled, null)
  georeplications               = try(var.container_registry_config.georeplications, null)
  network_rule_set              = try(var.container_registry_config.network_rule_set, null)
  retention_policy              = try(var.container_registry_config.retention_policy, null)
  trust_policy                  = try(var.container_registry_config.trust_policy, null)
  encryption                    = try(var.container_registry_config.encryption, null)
  identity_type                 = try(var.container_registry_config.identity_type, "SystemAssigned")
  identity_ids                  = try(var.container_registry_config.identity_ids, [])
  tags                          = var.tags
}

# Cosmos DB Module
module "cdb" {
  count = var.cdb_enabled && var.cdb_config != null ? 1 : 0

  source = "./cdb"

  name                               = var.cdb_name
  resource_group_name                = var.resource_group_name
  location                           = var.location
  offer_type                         = try(var.cdb_config.offer_type, null)
  kind                               = try(var.cdb_config.kind, null)
  consistency_level                  = try(var.cdb_config.consistency_level, null)
  max_interval_in_seconds            = try(var.cdb_config.max_interval_in_seconds, 5)
  max_staleness_prefix               = try(var.cdb_config.max_staleness_prefix, 100)
  capabilities                       = try(var.cdb_config.capabilities, null)
  geo_locations                      = var.cdb_config.geo_locations
  backup                             = try(var.cdb_config.backup, null)
  cors_rule                          = try(var.cdb_config.cors_rule, null)
  is_virtual_network_filter_enabled  = try(var.cdb_config.is_virtual_network_filter_enabled, false)
  virtual_network_rules              = try(var.cdb_config.virtual_network_rules, [])
  ip_range_filter                    = try(var.cdb_config.ip_range_filter, null) != null ? (can(tolist(var.cdb_config.ip_range_filter)) ? var.cdb_config.ip_range_filter : [var.cdb_config.ip_range_filter]) : null
  public_network_access_enabled      = try(var.cdb_config.public_network_access_enabled, null)
  access_key_metadata_writes_enabled = try(var.cdb_config.access_key_metadata_writes_enabled, true)
  local_authentication_disabled      = try(var.cdb_config.local_authentication_disabled, false)
  identity_type                      = try(var.cdb_config.identity_type, "SystemAssigned")
  identity_ids                       = try(var.cdb_config.identity_ids, [])
  databases                          = try(var.cdb_config.databases, {})
  containers                         = try(var.cdb_config.containers, {})
  default_indexing_mode              = try(var.cdb_config.default_indexing_mode, null)

  tags = var.tags
}

# PostgreSQL Module
module "postgres" {
  count = var.postgresql_enabled && var.postgresql_config != null ? 1 : 0

  source = "./postgres"

  name                          = var.postgresql_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  server_version                = try(var.postgresql_config.server_version, null)
  administrator_login           = var.postgresql_config.administrator_login
  administrator_password        = var.postgresql_config.administrator_password
  sku_name                      = try(var.postgresql_config.sku_name, null)
  storage_mb                    = try(var.postgresql_config.storage_mb, null)
  backup_retention_days         = try(var.postgresql_config.backup_retention_days, null)
  geo_redundant_backup_enabled  = try(var.postgresql_config.geo_redundant_backup_enabled, false)
  public_network_access_enabled = try(var.postgresql_config.public_network_access_enabled, null)
  maintenance_window            = try(var.postgresql_config.maintenance_window, null)
  high_availability             = try(var.postgresql_config.high_availability, null)
  identity_type                 = try(var.postgresql_config.identity_type, null)
  identity_ids                  = try(var.postgresql_config.identity_ids, [])
  firewall_rules                = try(var.postgresql_config.firewall_rules, {})
  databases                     = try(var.postgresql_config.databases, {})
  server_configurations         = try(var.postgresql_config.server_configurations, {})
  default_charset               = try(var.postgresql_config.default_charset, null)
  default_collation             = try(var.postgresql_config.default_collation, null)

  tags = var.tags
}

# Key Vault Secret IDs (will be created by afterjob module in root)
locals {
  key_vault_secret_ids = {} # Empty, secrets will be created by afterjob module in root
}
