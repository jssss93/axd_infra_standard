output "id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.this.name
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = var.public_ip_enabled && length(azurerm_public_ip.this) > 0 ? azurerm_public_ip.this[0].ip_address : null
}

output "public_ip_id" {
  description = "The ID of the public IP"
  value       = var.public_ip_enabled && length(azurerm_public_ip.this) > 0 ? azurerm_public_ip.this[0].id : null
}
