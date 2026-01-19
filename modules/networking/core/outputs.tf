# Virtual Network Outputs
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = azurerm_virtual_network.this.address_space
}

# Subnet Outputs
output "subnet_ids" {
  description = "Map of subnet keys to subnet IDs"
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

output "subnet_names" {
  description = "Map of subnet keys to subnet names"
  value       = { for k, s in azurerm_subnet.this : k => s.name }
}

output "subnets" {
  description = "Map of subnet keys to subnet objects"
  value       = azurerm_subnet.this
}

# Application Gateway Outputs
output "application_gateway_id" {
  description = "The ID of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(azurerm_application_gateway.this) > 0 ? azurerm_application_gateway.this[0].id : null
}

output "application_gateway_name" {
  description = "The name of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(azurerm_application_gateway.this) > 0 ? azurerm_application_gateway.this[0].name : null
}

output "application_gateway_public_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(azurerm_application_gateway.this) > 0 && length(azurerm_public_ip.agw) > 0 ? azurerm_public_ip.agw[0].ip_address : null
}

output "application_gateway_public_ip_id" {
  description = "The ID of the public IP"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(azurerm_public_ip.agw) > 0 ? azurerm_public_ip.agw[0].id : null
}
