# Data source for current client config (for tenant_id)
data "azurerm_client_config" "current" {}

# Container Registry Module
module "acr" {
  count = var.container_registry_enabled && var.container_registry_config != null ? 1 : 0

  source = "../acr"

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

# Key Vault Module
module "keyvault" {
  count = var.key_vault_enabled && var.key_vault_config != null ? 1 : 0

  source = "../keyvault"

  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = lookup(var.key_vault_config, "tenant_id", null) != null ? var.key_vault_config.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name            = lookup(var.key_vault_config, "sku_name", "standard")
  enabled_for_deployment          = lookup(var.key_vault_config, "enabled_for_deployment", false)
  enabled_for_disk_encryption     = lookup(var.key_vault_config, "enabled_for_disk_encryption", false)
  enabled_for_template_deployment = lookup(var.key_vault_config, "enabled_for_template_deployment", false)
  enable_rbac_authorization       = lookup(var.key_vault_config, "enable_rbac_authorization", true)
  public_network_access_enabled    = lookup(var.key_vault_config, "public_network_access_enabled", false)
  purge_protection_enabled         = lookup(var.key_vault_config, "purge_protection_enabled", false)
  soft_delete_retention_days      = lookup(var.key_vault_config, "soft_delete_retention_days", 90)
  network_acls                     = lookup(var.key_vault_config, "network_acls", null)
  contacts                         = lookup(var.key_vault_config, "contacts", null)
  access_policies                  = lookup(var.key_vault_config, "access_policies", {})

  tags = var.tags
}

# Key Vault Secrets for PaaS Services
# Note: Key Vault secrets creation requires public network access or private endpoint connection
# PostgreSQL 접속 정보
resource "azurerm_key_vault_secret" "postgresql_password" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? 1 : 0

  name         = "postgresql-password"
  value        = var.postgresql_config.administrator_password
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.postgres]
}

resource "azurerm_key_vault_secret" "postgresql_fqdn" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? 1 : 0

  name         = "postgresql-fqdn"
  value        = module.postgres[0].fqdn
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.postgres]
}

resource "azurerm_key_vault_secret" "postgresql_admin_login" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? 1 : 0

  name         = "postgresql-admin-login"
  value        = var.postgresql_config.administrator_login
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.postgres]
}

# Cosmos DB 접속 정보
resource "azurerm_key_vault_secret" "cosmosdb_endpoint" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? 1 : 0

  name         = "cosmosdb-endpoint"
  value        = module.cosmos[0].endpoint
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.cosmos]
}

resource "azurerm_key_vault_secret" "cosmosdb_primary_key" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? 1 : 0

  name         = "cosmosdb-primary-key"
  value        = module.cosmos[0].primary_key
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.cosmos]
}

resource "azurerm_key_vault_secret" "cosmosdb_secondary_key" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? 1 : 0

  name         = "cosmosdb-secondary-key"
  value        = module.cosmos[0].secondary_key
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.cosmos]
}

# ACR 접속 정보
resource "azurerm_key_vault_secret" "acr_login_server" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? 1 : 0

  name         = "acr-login-server"
  value        = module.acr[0].login_server
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.acr]
}

resource "azurerm_key_vault_secret" "acr_admin_username" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 && lookup(var.container_registry_config, "admin_enabled", false) ? 1 : 0

  name         = "acr-admin-username"
  value        = module.acr[0].admin_username
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  depends_on = [module.keyvault, module.acr]
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 && lookup(var.container_registry_config, "admin_enabled", false) ? 1 : 0

  name         = "acr-admin-password"
  value        = module.acr[0].admin_password
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  depends_on = [module.keyvault, module.acr]
}

# OpenAI 접속 정보
resource "azurerm_key_vault_secret" "openai_endpoint" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? 1 : 0

  name         = "openai-endpoint"
  value        = module.openai[0].endpoint
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.openai]
}

resource "azurerm_key_vault_secret" "openai_primary_key" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? 1 : 0

  name         = "openai-primary-key"
  value        = module.openai[0].primary_access_key
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.openai]
}

resource "azurerm_key_vault_secret" "openai_secondary_key" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? 1 : 0

  name         = "openai-secondary-key"
  value        = module.openai[0].secondary_access_key
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.openai]
}

# AI Foundry 접속 정보
resource "azurerm_key_vault_secret" "foundry_endpoint" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? 1 : 0

  name         = "foundry-endpoint"
  value        = module.foundry[0].cognitive_account_endpoint
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.foundry]
}

resource "azurerm_key_vault_secret" "foundry_primary_key" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? 1 : 0

  name         = "foundry-primary-key"
  value        = module.foundry[0].primary_access_key
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.foundry]
}

resource "azurerm_key_vault_secret" "foundry_secondary_key" {
  count = var.key_vault_enabled && var.key_vault_config != null && var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? 1 : 0

  name         = "foundry-secondary-key"
  value        = module.foundry[0].secondary_access_key
  content_type = "text/plain"
  key_vault_id = module.keyvault[0].id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }

  depends_on = [module.keyvault, module.foundry]
}

# Cosmos DB Module
module "cosmos" {
  count = var.cosmos_db_enabled && var.cosmos_db_config != null ? 1 : 0

  source = "../cosmos"

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

  source = "../postgres"

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
  identity_type                 = lookup(var.postgresql_config, "identity_type", "SystemAssigned")
  identity_ids                  = lookup(var.postgresql_config, "identity_ids", [])
  firewall_rules                = lookup(var.postgresql_config, "firewall_rules", {})
  databases                     = lookup(var.postgresql_config, "databases", {})
  server_configurations          = lookup(var.postgresql_config, "server_configurations", {})

  tags = var.tags
}

# AI Foundry Module
module "foundry" {
  count = var.foundry_enabled && var.foundry_config != null ? 1 : 0

  source = "../foundry"

  name                = var.foundry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  create_cognitive_account = lookup(var.foundry_config, "create_cognitive_account", true)
  cognitive_account_kind  = lookup(var.foundry_config, "cognitive_account_kind", "OpenAI")
  cognitive_account_sku   = lookup(var.foundry_config, "cognitive_account_sku", "S0")
  public_network_access_enabled = lookup(var.foundry_config, "public_network_access_enabled", false)
  identity_type                 = lookup(var.foundry_config, "identity_type", "SystemAssigned")
  identity_ids                  = lookup(var.foundry_config, "identity_ids", [])
  foundry_services               = lookup(var.foundry_config, "foundry_services", null)

  tags = var.tags
}

# OpenAI Module
module "openai" {
  count = var.openai_enabled && var.openai_config != null ? 1 : 0

  source = "../openai"

  name                = var.openai_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = lookup(var.openai_config, "sku_name", "S0")
  public_network_access_enabled = lookup(var.openai_config, "public_network_access_enabled", false)
  identity_type                 = lookup(var.openai_config, "identity_type", "SystemAssigned")
  identity_ids                  = lookup(var.openai_config, "identity_ids", [])
  deployments                   = lookup(var.openai_config, "deployments", {})

  tags = var.tags
}
