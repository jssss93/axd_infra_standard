# AI Foundry Outputs
output "foundry_id" {
  description = "The ID of the Azure AI Foundry hub"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].foundry_id : null
}

output "foundry_name" {
  description = "The name of the Azure AI Foundry hub"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].foundry_name : null
}

output "foundry_endpoint" {
  description = "The discovery URL (endpoint) of the Azure AI Foundry hub"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].foundry_endpoint : null
}

output "foundry_project_id" {
  description = "The ID of the Azure AI Foundry project (if created)"
  value       = var.foundry_enabled && var.foundry_config != null && length(module.foundry) > 0 ? module.foundry[0].project_id : null
}

output "foundry_project_name" {
  description = "The name of the Azure AI Foundry project (if created)"
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

output "openai_primary_access_key" {
  description = "The primary access key for the Azure OpenAI Account"
  value       = var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].primary_access_key : null
  sensitive   = true
}

output "openai_secondary_access_key" {
  description = "The secondary access key for the Azure OpenAI Account"
  value       = var.openai_enabled && var.openai_config != null && length(module.openai) > 0 ? module.openai[0].secondary_access_key : null
  sensitive   = true
}

# Note: key_vault_secret_ids output removed - secrets are now created by afterjob module in root
