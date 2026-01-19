output "id" {
  description = "The ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.id
}

output "name" {
  description = "The name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.name
}

output "fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_ids" {
  description = "Map of PostgreSQL Database IDs"
  value       = { for k, v in azurerm_postgresql_flexible_server_database.this : k => v.id }
}

# Key Vault Secret IDs
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs"
  value = {
    "postgresql-password"   = var.key_vault_id != null && length(azurerm_key_vault_secret.postgresql_password) > 0 ? azurerm_key_vault_secret.postgresql_password[0].id : null
    "postgresql-fqdn"       = var.key_vault_id != null && length(azurerm_key_vault_secret.postgresql_fqdn) > 0 ? azurerm_key_vault_secret.postgresql_fqdn[0].id : null
    "postgresql-admin-login" = var.key_vault_id != null && length(azurerm_key_vault_secret.postgresql_admin_login) > 0 ? azurerm_key_vault_secret.postgresql_admin_login[0].id : null
  }
}
