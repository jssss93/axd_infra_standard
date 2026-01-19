output "id" {
  description = "The ID of the Container Registry"
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "The name of the Container Registry"
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "The URL that can be used to log into the Container Registry"
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "The Username associated with the Container Registry Admin account"
  value       = azurerm_container_registry.this.admin_username
}

output "admin_password" {
  description = "The Password associated with the Container Registry Admin account"
  value       = azurerm_container_registry.this.admin_password
  sensitive   = true
}

output "identity" {
  description = "An identity block"
  value       = azurerm_container_registry.this.identity
}

# Key Vault Secret IDs
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs"
  value = {
    "acr-login-server"    = var.key_vault_id != null && length(azurerm_key_vault_secret.acr_login_server) > 0 ? azurerm_key_vault_secret.acr_login_server[0].id : null
    "acr-admin-username"  = var.key_vault_id != null && var.admin_enabled && length(azurerm_key_vault_secret.acr_admin_username) > 0 ? azurerm_key_vault_secret.acr_admin_username[0].id : null
    "acr-admin-password"  = var.key_vault_id != null && var.admin_enabled && length(azurerm_key_vault_secret.acr_admin_password) > 0 ? azurerm_key_vault_secret.acr_admin_password[0].id : null
  }
}
