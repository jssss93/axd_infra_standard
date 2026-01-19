output "id" {
  description = "The ID of the Private Endpoint"
  value       = azurerm_private_endpoint.this.id
}

output "name" {
  description = "The name of the Private Endpoint"
  value       = azurerm_private_endpoint.this.name
}

output "network_interface_id" {
  description = "The ID of the Network Interface associated with the Private Endpoint"
  value       = length(azurerm_private_endpoint.this.network_interface) > 0 ? azurerm_private_endpoint.this.network_interface[0].id : null
}

output "network_interface" {
  description = "The Network Interface associated with the Private Endpoint"
  value       = azurerm_private_endpoint.this.network_interface
}
