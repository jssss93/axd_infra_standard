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
