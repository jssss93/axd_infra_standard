# Key Vault Secrets for ACR
resource "azurerm_key_vault_secret" "acr_login_server" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "acr-login-server"
  value        = azurerm_container_registry.this.login_server
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "acr_admin_username" {
  count = var.key_vault_id != null && var.admin_enabled ? 1 : 0

  name         = "acr-admin-username"
  value        = azurerm_container_registry.this.admin_username
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  count = var.key_vault_id != null && var.admin_enabled ? 1 : 0

  name         = "acr-admin-password"
  value        = azurerm_container_registry.this.admin_password
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}
