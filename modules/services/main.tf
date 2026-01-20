# AI Foundry Module
module "foundry" {
  count = var.foundry_enabled && var.foundry_config != null ? 1 : 0

  source = "./foundry"

  name                = var.foundry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  storage_account_id         = lookup(var.foundry_config, "storage_account_id", null)
  storage_account_name       = lookup(var.foundry_config, "storage_account_name", null)
  storage_account_tier       = lookup(var.foundry_config, "storage_account_tier", "Standard")
  storage_account_replication_type = lookup(var.foundry_config, "storage_account_replication_type", "LRS")
  storage_account_public_network_access_enabled = lookup(var.foundry_config, "storage_account_public_network_access_enabled", false)
  key_vault_id               = var.key_vault_id
  public_network_access_enabled = lookup(var.foundry_config, "public_network_access_enabled", false)
  identity_type              = lookup(var.foundry_config, "identity_type", "SystemAssigned")
  identity_ids               = lookup(var.foundry_config, "identity_ids", [])
  create_project             = lookup(var.foundry_config, "create_project", false)
  project_name               = lookup(var.foundry_config, "project_name", null)
  project_identity_type      = lookup(var.foundry_config, "project_identity_type", null)
  project_identity_ids       = lookup(var.foundry_config, "project_identity_ids", [])
  deployments                = lookup(var.foundry_config, "deployments", {})

  tags = var.tags

  depends_on = [var.key_vault_id]
}

# OpenAI Module
module "openai" {
  count = var.openai_enabled && var.openai_config != null ? 1 : 0

  source = "./openai"

  name                = var.openai_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = lookup(var.openai_config, "sku_name", "S0")
  public_network_access_enabled = lookup(var.openai_config, "public_network_access_enabled", false)
  identity_type                 = lookup(var.openai_config, "identity_type", "SystemAssigned")
  identity_ids                  = lookup(var.openai_config, "identity_ids", [])
  deployments                   = lookup(var.openai_config, "deployments", {})
  key_vault_id                  = var.key_vault_id

  tags = var.tags
}

# Note: Key Vault secrets are now created by afterjob module in root
