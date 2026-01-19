output "foundry_id" {
  description = "The ID of the Azure AI Foundry hub"
  value       = azurerm_ai_foundry.foundry.id
}

output "foundry_name" {
  description = "The name of the Azure AI Foundry hub"
  value       = azurerm_ai_foundry.foundry.name
}

output "foundry_endpoint" {
  description = "The discovery URL (endpoint) of the Azure AI Foundry hub"
  value       = azurerm_ai_foundry.foundry.discovery_url
}

output "storage_account_id" {
  description = "The ID of the Storage Account used by Foundry (created, found via data source, or provided)"
  value       = var.storage_account_id != null ? var.storage_account_id : (
    length(data.azurerm_storage_account.foundry) > 0 ? data.azurerm_storage_account.foundry[0].id : (
      length(azurerm_storage_account.foundry) > 0 ? azurerm_storage_account.foundry[0].id : null
    )
  )
}

output "project_id" {
  description = "The ID of the Azure AI Foundry project (if created)"
  value       = var.create_project ? azurerm_ai_foundry_project.project[0].id : null
}

output "project_name" {
  description = "The name of the Azure AI Foundry project (if created)"
  value       = var.create_project ? azurerm_ai_foundry_project.project[0].name : null
}

output "deployment_ids" {
  description = "Map of deployment names to their resource IDs"
  value       = length(var.deployments) > 0 ? { for k, v in azurerm_cognitive_deployment.foundry_deployments : k => v.id } : {}
}

output "deployment_names" {
  description = "Map of deployment names"
  value       = length(var.deployments) > 0 ? { for k, v in azurerm_cognitive_deployment.foundry_deployments : k => v.name } : {}
}

# Key Vault Secret IDs
output "key_vault_secret_ids" {
  description = "Map of Key Vault secret names to their resource IDs"
  value = {
    "foundry-endpoint" = var.key_vault_id != null && length(azurerm_key_vault_secret.foundry_endpoint) > 0 ? azurerm_key_vault_secret.foundry_endpoint[0].id : null
  }
}
