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

# Key Vault Secret IDs
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs"
  value = {
    "openai-endpoint"     = var.key_vault_id != null && length(azurerm_key_vault_secret.openai_endpoint) > 0 ? azurerm_key_vault_secret.openai_endpoint[0].id : null
    "openai-primary-key"  = var.key_vault_id != null && length(azurerm_key_vault_secret.openai_primary_key) > 0 ? azurerm_key_vault_secret.openai_primary_key[0].id : null
    "openai-secondary-key" = var.key_vault_id != null && length(azurerm_key_vault_secret.openai_secondary_key) > 0 ? azurerm_key_vault_secret.openai_secondary_key[0].id : null
  }
}
