# Key Vault Secrets for PostgreSQL
resource "azurerm_key_vault_secret" "postgresql_password" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "postgresql-password"
  value        = var.administrator_password
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "postgresql_fqdn" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "postgresql-fqdn"
  value        = azurerm_postgresql_flexible_server.this.fqdn
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "postgresql_admin_login" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "postgresql-admin-login"
  value        = var.administrator_login
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}
