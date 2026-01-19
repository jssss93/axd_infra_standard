output "resource_group_id" {
  description = "The ID of the Resource Group"
  value       = module.rg.id
}

output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = module.rg.name
}

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = module.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet keys to subnet IDs"
  value       = module.subnets.subnet_ids
}

output "subnet_names" {
  description = "Map of subnet keys to subnet names"
  value       = module.subnets.subnet_names
}

output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value       = module.compute.container_app_environment_id
}

output "container_app_environment_name" {
  description = "The name of the Container App Environment"
  value       = module.compute.container_app_environment_name
}

output "container_app_ids" {
  description = "Map of Container App IDs"
  value       = module.compute.container_app_ids
}

output "container_app_fqdns" {
  description = "Map of Container App FQDNs"
  value       = module.compute.container_app_fqdns
}

output "application_gateway_id" {
  description = "The ID of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(module.application_gateway) > 0 ? module.application_gateway[0].id : null
}

output "application_gateway_public_ip" {
  description = "The public IP address of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(module.application_gateway) > 0 ? module.application_gateway[0].public_ip_address : null
}

output "application_gateway_public_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(module.application_gateway) > 0 ? module.application_gateway[0].public_ip_address : null
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

# Key Vault Secret IDs (aggregated from service modules)
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs (aggregated from all service modules)"
  value = merge(
    var.container_registry_enabled && var.container_registry_config != null && length(module.acr) > 0 ? module.acr[0].key_vault_secret_ids : {},
    var.cosmos_db_enabled && var.cosmos_db_config != null && length(module.cosmos) > 0 ? module.cosmos[0].key_vault_secret_ids : {},
    var.postgresql_enabled && var.postgresql_config != null && length(module.postgres) > 0 ? module.postgres[0].key_vault_secret_ids : {},
    var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].key_vault_secret_ids : {},
    var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].key_vault_secret_ids : {}
  )
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

# AI Foundry Outputs
output "foundry_cognitive_account_id" {
  description = "The ID of the Foundry Cognitive Services Account"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].foundry_id : null
}

output "foundry_cognitive_account_name" {
  description = "The name of the Foundry Cognitive Services Account"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].foundry_name : null
}

output "foundry_cognitive_account_endpoint" {
  description = "The endpoint of the Foundry Cognitive Services Account"
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
  description = "The ID of the Azure OpenAI Account"
  value       = var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].id : null
}

output "openai_name" {
  description = "The name of the Azure OpenAI Account"
  value       = var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].name : null
}

output "openai_endpoint" {
  description = "The endpoint of the Azure OpenAI Account"
  value       = var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].endpoint : null
}

output "openai_deployment_ids" {
  description = "Map of Azure OpenAI Deployment IDs"
  value       = var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].deployment_ids : {}
}
