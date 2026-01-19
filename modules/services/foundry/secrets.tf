# Key Vault Secrets for Foundry
resource "azurerm_key_vault_secret" "foundry_endpoint" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "foundry-endpoint"
  value        = azurerm_ai_foundry.foundry.discovery_url
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}
