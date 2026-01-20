# Key Vault Secret IDs
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs"
  value = {
    "acr-login-server"     = var.key_vault_id != null && length(azurerm_key_vault_secret.acr_login_server) > 0 ? azurerm_key_vault_secret.acr_login_server[0].id : null
    "acr-admin-username"   = var.key_vault_id != null && length(azurerm_key_vault_secret.acr_admin_username) > 0 ? azurerm_key_vault_secret.acr_admin_username[0].id : null
    "acr-admin-password"   = var.key_vault_id != null && length(azurerm_key_vault_secret.acr_admin_password) > 0 ? azurerm_key_vault_secret.acr_admin_password[0].id : null
    "cosmosdb-endpoint"    = var.key_vault_id != null && length(azurerm_key_vault_secret.cosmosdb_endpoint) > 0 ? azurerm_key_vault_secret.cosmosdb_endpoint[0].id : null
    "cosmosdb-primary-key" = var.key_vault_id != null && length(azurerm_key_vault_secret.cosmosdb_primary_key) > 0 ? azurerm_key_vault_secret.cosmosdb_primary_key[0].id : null
    "cosmosdb-secondary-key" = var.key_vault_id != null && length(azurerm_key_vault_secret.cosmosdb_secondary_key) > 0 ? azurerm_key_vault_secret.cosmosdb_secondary_key[0].id : null
    "postgresql-password"  = var.key_vault_id != null && length(azurerm_key_vault_secret.postgresql_password) > 0 ? azurerm_key_vault_secret.postgresql_password[0].id : null
    "postgresql-fqdn"      = var.key_vault_id != null && length(azurerm_key_vault_secret.postgresql_fqdn) > 0 ? azurerm_key_vault_secret.postgresql_fqdn[0].id : null
    "postgresql-admin-login" = var.key_vault_id != null && length(azurerm_key_vault_secret.postgresql_admin_login) > 0 ? azurerm_key_vault_secret.postgresql_admin_login[0].id : null
    "foundry-endpoint"     = var.key_vault_id != null && length(azurerm_key_vault_secret.foundry_endpoint) > 0 ? azurerm_key_vault_secret.foundry_endpoint[0].id : null
    "openai-endpoint"      = var.key_vault_id != null && length(azurerm_key_vault_secret.openai_endpoint) > 0 ? azurerm_key_vault_secret.openai_endpoint[0].id : null
    "openai-primary-key"   = var.key_vault_id != null && length(azurerm_key_vault_secret.openai_primary_key) > 0 ? azurerm_key_vault_secret.openai_primary_key[0].id : null
    "openai-secondary-key" = var.key_vault_id != null && length(azurerm_key_vault_secret.openai_secondary_key) > 0 ? azurerm_key_vault_secret.openai_secondary_key[0].id : null
  }
}
