output "id" {
  description = "The ID of the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.this.id
}

output "name" {
  description = "The name of the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.this.name
}

output "endpoint" {
  description = "The endpoint of the Cosmos DB Account"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "read_endpoints" {
  description = "A list of read endpoints available for this CosmosDB account"
  value       = azurerm_cosmosdb_account.this.read_endpoints
}

output "write_endpoints" {
  description = "A list of write endpoints available for this CosmosDB account"
  value       = azurerm_cosmosdb_account.this.write_endpoints
}

output "primary_key" {
  description = "The Primary key for the CosmosDB Account"
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "The Secondary key for the CosmosDB Account"
  value       = azurerm_cosmosdb_account.this.secondary_key
  sensitive   = true
}

# primary_connection_string과 secondary_connection_string은 AzureRM 4.40에서 지원되지 않음
# output "primary_connection_string" {
#   description = "The Primary connection string for the CosmosDB Account"
#   value       = azurerm_cosmosdb_account.this.primary_connection_string
#   sensitive   = true
# }

# output "secondary_connection_string" {
#   description = "The Secondary connection string for the CosmosDB Account"
#   value       = azurerm_cosmosdb_account.this.secondary_connection_string
#   sensitive   = true
# }

output "database_ids" {
  description = "Map of Cosmos DB SQL Database IDs"
  value       = { for k, v in azurerm_cosmosdb_sql_database.this : k => v.id }
}

output "container_ids" {
  description = "Map of Cosmos DB SQL Container IDs"
  value       = { for k, v in azurerm_cosmosdb_sql_container.this : k => v.id }
}

# Key Vault Secret IDs
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs"
  value = {
    "cosmosdb-endpoint"     = var.key_vault_id != null && length(azurerm_key_vault_secret.cosmosdb_endpoint) > 0 ? azurerm_key_vault_secret.cosmosdb_endpoint[0].id : null
    "cosmosdb-primary-key"  = var.key_vault_id != null && length(azurerm_key_vault_secret.cosmosdb_primary_key) > 0 ? azurerm_key_vault_secret.cosmosdb_primary_key[0].id : null
    "cosmosdb-secondary-key" = var.key_vault_id != null && length(azurerm_key_vault_secret.cosmosdb_secondary_key) > 0 ? azurerm_key_vault_secret.cosmosdb_secondary_key[0].id : null
  }
}
