# Key Vault Secrets for ACR
resource "azurerm_key_vault_secret" "acr_login_server" {
  count = var.key_vault_id != null && var.acr_login_server != null ? 1 : 0

  name         = "acr-login-server"
  value        = var.acr_login_server
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "acr_admin_username" {
  count = var.key_vault_id != null && var.acr_admin_username != null ? 1 : 0

  name         = "acr-admin-username"
  value        = var.acr_admin_username
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  count = var.key_vault_id != null && var.acr_admin_password != null ? 1 : 0

  name         = "acr-admin-password"
  value        = var.acr_admin_password
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Key Vault Secrets for Cosmos DB
resource "azurerm_key_vault_secret" "cosmosdb_endpoint" {
  count = var.key_vault_id != null && var.cosmosdb_endpoint != null ? 1 : 0

  name         = "cosmosdb-endpoint"
  value        = var.cosmosdb_endpoint
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "cosmosdb_primary_key" {
  count = var.key_vault_id != null && var.cosmosdb_primary_key != null ? 1 : 0

  name         = "cosmosdb-primary-key"
  value        = var.cosmosdb_primary_key
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "cosmosdb_secondary_key" {
  count = var.key_vault_id != null && var.cosmosdb_secondary_key != null ? 1 : 0

  name         = "cosmosdb-secondary-key"
  value        = var.cosmosdb_secondary_key
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Key Vault Secrets for PostgreSQL
resource "azurerm_key_vault_secret" "postgresql_password" {
  count = var.key_vault_id != null && var.postgresql_password != null ? 1 : 0

  name         = "postgresql-password"
  value        = var.postgresql_password
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "postgresql_fqdn" {
  count = var.key_vault_id != null && var.postgresql_fqdn != null ? 1 : 0

  name         = "postgresql-fqdn"
  value        = var.postgresql_fqdn
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "postgresql_admin_login" {
  count = var.key_vault_id != null && var.postgresql_admin_login != null ? 1 : 0

  name         = "postgresql-admin-login"
  value        = var.postgresql_admin_login
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Key Vault Secrets for Foundry
resource "azurerm_key_vault_secret" "foundry_endpoint" {
  count = var.key_vault_id != null && var.foundry_endpoint != null ? 1 : 0

  name         = "foundry-endpoint"
  value        = var.foundry_endpoint
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

# Key Vault Secrets for OpenAI
resource "azurerm_key_vault_secret" "openai_endpoint" {
  count = var.key_vault_id != null && var.openai_endpoint != null ? 1 : 0

  name         = "openai-endpoint"
  value        = var.openai_endpoint
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "openai_primary_key" {
  count = var.key_vault_id != null && var.openai_primary_key != null ? 1 : 0

  name         = "openai-primary-key"
  value        = var.openai_primary_key
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "openai_secondary_key" {
  count = var.key_vault_id != null && var.openai_secondary_key != null ? 1 : 0

  name         = "openai-secondary-key"
  value        = var.openai_secondary_key
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}
