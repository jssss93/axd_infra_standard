# Key Vault Secrets for OpenAI
resource "azurerm_key_vault_secret" "openai_endpoint" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "openai-endpoint"
  value        = azurerm_cognitive_account.openai.endpoint
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "openai_primary_key" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "openai-primary-key"
  value        = azurerm_cognitive_account.openai.primary_access_key
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "openai_secondary_key" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "openai-secondary-key"
  value        = azurerm_cognitive_account.openai.secondary_access_key
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}
