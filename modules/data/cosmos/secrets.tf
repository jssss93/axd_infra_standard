# Key Vault Secrets for Cosmos DB
resource "azurerm_key_vault_secret" "cosmosdb_endpoint" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "cosmosdb-endpoint"
  value        = azurerm_cosmosdb_account.this.endpoint
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "cosmosdb_primary_key" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "cosmosdb-primary-key"
  value        = azurerm_cosmosdb_account.this.primary_key
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_key_vault_secret" "cosmosdb_secondary_key" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "cosmosdb-secondary-key"
  value        = azurerm_cosmosdb_account.this.secondary_key
  content_type = "text/plain"
  key_vault_id = var.key_vault_id

  tags = var.tags

  lifecycle {
    ignore_changes = all
  }
}
