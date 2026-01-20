# AI Foundry Module
module "foundry" {
  count = var.foundry_enabled && var.foundry_config != null ? 1 : 0

  source = "./foundry"

  name                                          = var.foundry_name
  resource_group_name                           = var.resource_group_name
  location                                      = var.location
  storage_account_id                            = try(var.foundry_config.storage_account_id, null)
  storage_account_name                          = try(var.foundry_config.storage_account_name, null)
  storage_account_tier                          = try(var.foundry_config.storage_account_tier, null)
  storage_account_replication_type              = try(var.foundry_config.storage_account_replication_type, null)
  storage_account_public_network_access_enabled = try(var.foundry_config.storage_account_public_network_access_enabled, null)
  storage_account_name_suffix                   = try(var.foundry_config.storage_account_name_suffix, null)
  key_vault_id                                  = var.key_vault_id
  public_network_access_enabled                 = try(var.foundry_config.public_network_access_enabled, null)
  identity_type                                 = try(var.foundry_config.identity_type, null)
  identity_ids                                  = try(var.foundry_config.identity_ids, [])
  create_project                                = try(var.foundry_config.create_project, false)
  project_name                                  = try(var.foundry_config.project_name, null)
  project_identity_type                         = try(var.foundry_config.project_identity_type, null)
  project_identity_ids                          = try(var.foundry_config.project_identity_ids, [])
  deployments                                   = try(var.foundry_config.deployments, {})
  project_deployments                           = try(var.foundry_config.project_deployments, {})
  cognitive_account_sku_name                    = try(var.foundry_config.cognitive_account_sku_name, null)
  cognitive_account_kind                        = try(var.foundry_config.cognitive_account_kind, null)
  cognitive_account_name_suffix                 = try(var.foundry_config.cognitive_account_name_suffix, null)
  default_model_format                          = try(var.foundry_config.default_model_format, null)
  default_version_upgrade_option                = try(var.foundry_config.default_version_upgrade_option, null)
  default_deployment_sku_type                   = try(var.foundry_config.default_deployment_sku_type, null)

  tags = var.tags

  depends_on = [var.key_vault_id]
}

# OpenAI Module
module "openai" {
  count = var.openai_enabled && var.openai_config != null ? 1 : 0

  source = "./openai"

  name                           = var.openai_name
  resource_group_name            = var.resource_group_name
  location                       = var.location
  sku_name                       = try(var.openai_config.sku_name, null)
  kind                           = try(var.openai_config.kind, null)
  public_network_access_enabled  = try(var.openai_config.public_network_access_enabled, null)
  identity_type                  = try(var.openai_config.identity_type, null)
  identity_ids                   = try(var.openai_config.identity_ids, [])
  deployments                    = try(var.openai_config.deployments, {})
  default_model_format           = try(var.openai_config.default_model_format, null)
  default_version_upgrade_option = try(var.openai_config.default_version_upgrade_option, null)
  default_deployment_sku_type    = try(var.openai_config.default_deployment_sku_type, null)
  key_vault_id                   = var.key_vault_id

  tags = var.tags
}

# Note: Key Vault secrets are now created by afterjob module in root
