# Key Vault Secrets - using count with enabled flags to avoid resource output dependencies
# Key Vault Secrets for ACR
resource "azurerm_key_vault_secret" "acr_login_server" {
  count = var.key_vault_enabled && var.container_registry_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.acr_login_server
  value        = try(var.acr_login_server, "")
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "acr_admin_username" {
  count = var.key_vault_enabled && var.container_registry_enabled && var.acr_admin_username != null ? 1 : 0

  name         = local.secret_names.acr_admin_username
  value        = var.acr_admin_username
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  count = var.key_vault_enabled && var.container_registry_enabled && var.acr_admin_password != null ? 1 : 0

  name         = local.secret_names.acr_admin_password
  value        = var.acr_admin_password
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Key Vault Secrets for Cosmos DB
resource "azurerm_key_vault_secret" "cosmosdb_endpoint" {
  count = var.key_vault_enabled && var.cosmos_db_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.cosmosdb_endpoint
  value        = var.cosmosdb_endpoint
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "cosmosdb_primary_key" {
  count = var.key_vault_enabled && var.cosmos_db_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.cosmosdb_primary_key
  value        = var.cosmosdb_primary_key
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "cosmosdb_secondary_key" {
  count = var.key_vault_enabled && var.cosmos_db_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.cosmosdb_secondary_key
  value        = var.cosmosdb_secondary_key
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Key Vault Secrets for PostgreSQL
resource "azurerm_key_vault_secret" "postgresql_password" {
  count = var.key_vault_enabled && var.postgresql_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.postgresql_password
  value        = var.postgresql_password
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "postgresql_fqdn" {
  count = var.key_vault_enabled && var.postgresql_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.postgresql_fqdn
  value        = var.postgresql_fqdn
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "postgresql_admin_login" {
  count = var.key_vault_enabled && var.postgresql_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.postgresql_admin_login
  value        = var.postgresql_admin_login
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Key Vault Secrets for Foundry
resource "azurerm_key_vault_secret" "foundry_endpoint" {
  count = var.key_vault_enabled && var.foundry_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.foundry_endpoint
  value        = var.foundry_endpoint
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Key Vault Secrets for OpenAI
resource "azurerm_key_vault_secret" "openai_endpoint" {
  count = var.key_vault_enabled && var.openai_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.openai_endpoint
  value        = var.openai_endpoint
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "openai_primary_key" {
  count = var.key_vault_enabled && var.openai_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.openai_primary_key
  value        = var.openai_primary_key
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "openai_secondary_key" {
  count = var.key_vault_enabled && var.openai_enabled && var.create_secrets ? 1 : 0

  name         = local.secret_names.openai_secondary_key
  value        = var.openai_secondary_key
  content_type = local.secret_content_type
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}
