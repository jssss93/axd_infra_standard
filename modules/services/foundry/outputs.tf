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

output "project_id" {
  description = "The ID of the Azure AI Foundry project (if created)"
  value       = var.create_project ? azurerm_ai_foundry_project.project[0].id : null
}

output "project_name" {
  description = "The name of the Azure AI Foundry project (if created)"
  value       = var.create_project ? azurerm_ai_foundry_project.project[0].name : null
}
