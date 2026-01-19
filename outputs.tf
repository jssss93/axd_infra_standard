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
  value       = module.networking_core.vnet_id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = module.networking_core.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet keys to subnet IDs"
  value       = module.networking_core.subnet_ids
}

output "subnet_names" {
  description = "Map of subnet keys to subnet names"
  value       = module.networking_core.subnet_names
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
  value       = module.networking_core.application_gateway_id
}

output "application_gateway_public_ip" {
  description = "The public IP address of the Application Gateway"
  value       = module.networking_core.application_gateway_public_ip_address
}

output "application_gateway_public_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = module.networking_core.application_gateway_public_ip_address
}

# Container Registry Outputs
output "container_registry_id" {
  description = "The ID of the Container Registry"
  value       = module.infra.container_registry_id
}

output "container_registry_name" {
  description = "The name of the Container Registry"
  value       = module.infra.container_registry_name
}

output "container_registry_login_server" {
  description = "The login server URL of the Container Registry"
  value       = module.infra.container_registry_id != null ? "${module.infra.container_registry_name}.azurecr.io" : null
}

# Key Vault Outputs
output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = module.infra.key_vault_id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = module.infra.key_vault_name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.infra.key_vault_uri
}

# Cosmos DB Outputs
output "cosmos_db_id" {
  description = "The ID of the Cosmos DB Account"
  value       = module.infra.cosmos_db_id
}

output "cosmos_db_name" {
  description = "The name of the Cosmos DB Account"
  value       = module.infra.cosmos_db_name
}

output "cosmos_db_endpoint" {
  description = "The endpoint of the Cosmos DB Account"
  value       = module.infra.cosmos_db_endpoint
}

output "cosmos_db_database_ids" {
  description = "Map of Cosmos DB SQL Database IDs"
  value       = null  # module.infra에 database_ids output이 없음
}

output "cosmos_db_container_ids" {
  description = "Map of Cosmos DB SQL Container IDs"
  value       = null  # module.infra에 container_ids output이 없음
}

# PostgreSQL Outputs
output "postgresql_id" {
  description = "The ID of the PostgreSQL Flexible Server"
  value       = module.infra.postgresql_id
}

output "postgresql_name" {
  description = "The name of the PostgreSQL Flexible Server"
  value       = module.infra.postgresql_name
}

output "postgresql_fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server"
  value       = module.infra.postgresql_fqdn
}

output "postgresql_database_ids" {
  description = "Map of PostgreSQL Database IDs"
  value       = null  # module.infra에 database_ids output이 없음
}

# AI Foundry Outputs
output "foundry_cognitive_account_id" {
  description = "The ID of the Foundry Cognitive Services Account"
  value       = module.infra.foundry_id
}

output "foundry_cognitive_account_name" {
  description = "The name of the Foundry Cognitive Services Account"
  value       = module.infra.foundry_name
}

output "foundry_cognitive_account_endpoint" {
  description = "The endpoint of the Foundry Cognitive Services Account"
  value       = null  # module.infra에 endpoint output이 없음
}

# OpenAI Outputs
output "openai_id" {
  description = "The ID of the Azure OpenAI Account"
  value       = module.infra.openai_id
}

output "openai_name" {
  description = "The name of the Azure OpenAI Account"
  value       = module.infra.openai_name
}

output "openai_endpoint" {
  description = "The endpoint of the Azure OpenAI Account"
  value       = null  # module.infra에 endpoint output이 없음
}

output "openai_deployment_ids" {
  description = "Map of Azure OpenAI Deployment IDs"
  value       = null  # module.infra에 deployment_ids output이 없음
}
