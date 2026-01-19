output "cognitive_account_id" {
  description = "The ID of the Cognitive Services Account"
  value       = var.create_cognitive_account ? azurerm_cognitive_account.foundry[0].id : null
}

output "cognitive_account_name" {
  description = "The name of the Cognitive Services Account"
  value       = var.create_cognitive_account ? azurerm_cognitive_account.foundry[0].name : null
}

output "cognitive_account_endpoint" {
  description = "The endpoint of the Cognitive Services Account"
  value       = var.create_cognitive_account ? azurerm_cognitive_account.foundry[0].endpoint : null
}

output "primary_access_key" {
  description = "The primary access key for the Cognitive Services Account"
  value       = var.create_cognitive_account ? azurerm_cognitive_account.foundry[0].primary_access_key : null
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the Cognitive Services Account"
  value       = var.create_cognitive_account ? azurerm_cognitive_account.foundry[0].secondary_access_key : null
  sensitive   = true
}
