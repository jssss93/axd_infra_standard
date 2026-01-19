# Container Registry Outputs
output "container_registry_id" {
  description = "The ID of the Container Registry"
  value       = var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? module.acr[0].id : null
}

output "container_registry_name" {
  description = "The name of the Container Registry"
  value       = var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? module.acr[0].name : null
}

# Key Vault Outputs
output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = var.key_vault_enabled && var.key_vault_config != null && length(module.keyvault) > 0 ? module.keyvault[0].id : null
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = var.key_vault_enabled && var.key_vault_config != null && length(module.keyvault) > 0 ? module.keyvault[0].name : null
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = var.key_vault_enabled && var.key_vault_config != null && length(module.keyvault) > 0 ? module.keyvault[0].vault_uri : null
}

# Key Vault Secret IDs
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs"
  value = {
    "acr-login-server"      = var.key_vault_enabled && var.key_vault_config != null && var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 && length(azurerm_key_vault_secret.acr_login_server) > 0 ? azurerm_key_vault_secret.acr_login_server[0].id : null
    "cosmosdb-endpoint"     = var.key_vault_enabled && var.key_vault_config != null && var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 && length(azurerm_key_vault_secret.cosmosdb_endpoint) > 0 ? azurerm_key_vault_secret.cosmosdb_endpoint[0].id : null
    "cosmosdb-primary-key"  = var.key_vault_enabled && var.key_vault_config != null && var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 && length(azurerm_key_vault_secret.cosmosdb_primary_key) > 0 ? azurerm_key_vault_secret.cosmosdb_primary_key[0].id : null
    "cosmosdb-secondary-key" = var.key_vault_enabled && var.key_vault_config != null && var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 && length(azurerm_key_vault_secret.cosmosdb_secondary_key) > 0 ? azurerm_key_vault_secret.cosmosdb_secondary_key[0].id : null
    "foundry-endpoint"      = var.key_vault_enabled && var.key_vault_config != null && var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 && length(azurerm_key_vault_secret.foundry_endpoint) > 0 ? azurerm_key_vault_secret.foundry_endpoint[0].id : null
    "openai-endpoint"       = var.key_vault_enabled && var.key_vault_config != null && var.openai_enabled && var.openai_config != null && length(module.openai) > 0 && length(azurerm_key_vault_secret.openai_endpoint) > 0 ? azurerm_key_vault_secret.openai_endpoint[0].id : null
    "openai-primary-key"    = var.key_vault_enabled && var.key_vault_config != null && var.openai_enabled && var.openai_config != null && length(module.openai) > 0 && length(azurerm_key_vault_secret.openai_primary_key) > 0 ? azurerm_key_vault_secret.openai_primary_key[0].id : null
    "openai-secondary-key"   = var.key_vault_enabled && var.key_vault_config != null && var.openai_enabled && var.openai_config != null && length(module.openai) > 0 && length(azurerm_key_vault_secret.openai_secondary_key) > 0 ? azurerm_key_vault_secret.openai_secondary_key[0].id : null
    "postgresql-password"   = var.key_vault_enabled && var.key_vault_config != null && var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 && length(azurerm_key_vault_secret.postgresql_password) > 0 ? azurerm_key_vault_secret.postgresql_password[0].id : null
    "postgresql-fqdn"       = var.key_vault_enabled && var.key_vault_config != null && var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 && length(azurerm_key_vault_secret.postgresql_fqdn) > 0 ? azurerm_key_vault_secret.postgresql_fqdn[0].id : null
    "postgresql-admin-login" = var.key_vault_enabled && var.key_vault_config != null && var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 && length(azurerm_key_vault_secret.postgresql_admin_login) > 0 ? azurerm_key_vault_secret.postgresql_admin_login[0].id : null
  }
}

# Cosmos DB Outputs
output "cosmos_db_id" {
  description = "The ID of the Cosmos DB Account"
  value       = var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].id : null
}

output "cosmos_db_name" {
  description = "The name of the Cosmos DB Account"
  value       = var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].name : null
}

output "cosmos_db_endpoint" {
  description = "The endpoint of the Cosmos DB Account"
  value       = var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].endpoint : null
}

# PostgreSQL Outputs
output "postgresql_id" {
  description = "The ID of the PostgreSQL Flexible Server"
  value       = var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? module.postgres[0].id : null
}

output "postgresql_name" {
  description = "The name of the PostgreSQL Flexible Server"
  value       = var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? module.postgres[0].name : null
}

output "postgresql_fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server"
  value       = var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? module.postgres[0].fqdn : null
}

# AI Foundry Outputs
output "foundry_id" {
  description = "The ID of the AI Foundry hub"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].foundry_id : null
}

output "foundry_name" {
  description = "The name of the AI Foundry hub"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].foundry_name : null
}

output "foundry_endpoint" {
  description = "The endpoint of the AI Foundry hub"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].foundry_endpoint : null
}

output "foundry_project_id" {
  description = "The ID of the AI Foundry project (if created)"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].project_id : null
}

output "foundry_project_name" {
  description = "The name of the AI Foundry project (if created)"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].project_name : null
}

# OpenAI Outputs
output "openai_id" {
  description = "The ID of the OpenAI"
  value       = var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].id : null
}

output "openai_name" {
  description = "The name of the OpenAI"
  value       = var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].name : null
}
