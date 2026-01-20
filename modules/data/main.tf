# Data source for current client config (for tenant_id)
data "azurerm_client_config" "current" {}

# Key Vault Module (must be created first for other services)
module "keyvault" {
  count = var.key_vault_enabled && var.key_vault_config != null ? 1 : 0

  source = "./keyvault"

  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
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

  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
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
  tags = var.tags
}

# Cosmos DB Module
module "cosmos" {
  count = var.cosmos_db_enabled && var.cosmos_db_config != null ? 1 : 0

  source = "./cosmos"

  name                = var.cosmos_db_name
  resource_group_name = var.resource_group_name
  location            = var.location
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

  tags = var.tags
}

# PostgreSQL Module
module "postgres" {
  count = var.postgresql_enabled && var.postgresql_config != null ? 1 : 0

  source = "./postgres"

  name                = var.postgresql_name
  resource_group_name = var.resource_group_name
  location            = var.location
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

  tags = var.tags
}

# Key Vault Secret IDs (will be created by afterjob module in root)
locals {
  key_vault_secret_ids = {}  # Empty, secrets will be created by afterjob module in root
}
