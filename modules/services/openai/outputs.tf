output "id" {
  description = "The ID of the Azure OpenAI Account"
  value       = azurerm_cognitive_account.openai.id
}

output "name" {
  description = "The name of the Azure OpenAI Account"
  value       = azurerm_cognitive_account.openai.name
}

output "endpoint" {
  description = "The endpoint of the Azure OpenAI Account"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "primary_access_key" {
  description = "The primary access key for the Azure OpenAI Account"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the Azure OpenAI Account"
  value       = azurerm_cognitive_account.openai.secondary_access_key
  sensitive   = true
}

output "deployment_ids" {
  description = "Map of Azure OpenAI Deployment IDs"
  value       = { for k, v in azurerm_cognitive_deployment.this : k => v.id }
}

output "deployments" {
  description = "Map of Azure OpenAI Deployment objects"
  value       = azurerm_cognitive_deployment.this
}

# Note: Key Vault secrets are now created by afterjob module in root
