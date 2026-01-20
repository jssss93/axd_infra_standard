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

# Container Registry Outputs
output "container_registry_id" {
  description = "The ID of the Container Registry"
  value       = var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? module.acr[0].id : null
}

output "container_registry_name" {
  description = "The name of the Container Registry"
  value       = var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? module.acr[0].name : null
}

output "container_registry_login_server" {
  description = "The login server URL of the Container Registry"
  value       = var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? module.acr[0].login_server : null
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

output "cosmos_db_database_ids" {
  description = "Map of Cosmos DB SQL Database IDs"
  value       = var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].database_ids : {}
}

output "cosmos_db_container_ids" {
  description = "Map of Cosmos DB SQL Container IDs"
  value       = var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].container_ids : {}
}

output "cosmos_db_primary_key" {
  description = "The Primary key for the CosmosDB Account"
  value       = var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].primary_key : null
  sensitive   = true
}

output "cosmos_db_secondary_key" {
  description = "The Secondary key for the CosmosDB Account"
  value       = var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].secondary_key : null
  sensitive   = true
}

output "container_registry_admin_username" {
  description = "The Username associated with the Container Registry Admin account"
  value       = var.container_registry_enabled && var.container_registry_config != null && lookup(var.container_registry_config, "admin_enabled", false) && length(module.acr) > 0 ? module.acr[0].admin_username : null
}

output "container_registry_admin_password" {
  description = "The Password associated with the Container Registry Admin account"
  value       = var.container_registry_enabled && var.container_registry_config != null && lookup(var.container_registry_config, "admin_enabled", false) && length(module.acr) > 0 ? module.acr[0].admin_password : null
  sensitive   = true
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

output "postgresql_database_ids" {
  description = "Map of PostgreSQL Database IDs"
  value       = var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? module.postgres[0].database_ids : {}
}

# Key Vault Secret IDs (created by afterjob module in root)
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs (created by afterjob module in root)"
  value       = {}  # Empty, secrets are created by afterjob module in root
}
