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

output "cognitive_account_id" {
  description = "The ID of the Cognitive Services Account for Foundry Project (created when project_deployments are configured)"
  value       = var.create_project && length(var.project_deployments) > 0 && length(azurerm_cognitive_account.project) > 0 ? azurerm_cognitive_account.project[0].id : null
}

output "cognitive_account_name" {
  description = "The name of the Cognitive Services Account for Foundry Project"
  value       = var.create_project && length(var.project_deployments) > 0 && length(azurerm_cognitive_account.project) > 0 ? azurerm_cognitive_account.project[0].name : null
}

output "storage_account_id" {
  description = "The ID of the Storage Account used by Foundry (created, found via data source, or provided)"
  value = var.storage_account_id != null ? var.storage_account_id : (
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

# Note: Hub 레벨 deployments는 제거됨 - Project 레벨에만 배포

output "project_cognitive_account_id" {
  description = "The ID of the Cognitive Services Account for Foundry Project"
  value       = var.create_project && length(var.project_deployments) > 0 && length(azurerm_cognitive_account.project) > 0 ? azurerm_cognitive_account.project[0].id : null
}

output "project_cognitive_account_name" {
  description = "The name of the Cognitive Services Account for Foundry Project"
  value       = var.create_project && length(var.project_deployments) > 0 && length(azurerm_cognitive_account.project) > 0 ? azurerm_cognitive_account.project[0].name : null
}

output "project_deployment_ids" {
  description = "Map of deployment names to their resource IDs (Project level)"
  value       = var.create_project && length(var.project_deployments) > 0 ? { for k, v in azurerm_cognitive_deployment.project_deployments : k => v.id } : {}
}

output "project_deployment_names" {
  description = "Map of deployment names (Project level)"
  value       = var.create_project && length(var.project_deployments) > 0 ? { for k, v in azurerm_cognitive_deployment.project_deployments : k => v.name } : {}
}

# Note: Key Vault secrets are now created by afterjob module in root
