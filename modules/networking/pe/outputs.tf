# Private DNS Zone Outputs
output "private_dns_zone_ids" {
  description = "Map of Private DNS Zone keys to their IDs"
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.id }
}

output "private_dns_zone_names" {
  description = "Map of Private DNS Zone keys to their names"
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.name }
}

# Private Endpoint Outputs
output "private_endpoint_ids" {
  description = "Map of Private Endpoint keys to their IDs"
  value       = { for k, v in azurerm_private_endpoint.this : k => v.id }
}

output "private_endpoint_names" {
  description = "Map of Private Endpoint keys to their names"
  value       = { for k, v in azurerm_private_endpoint.this : k => v.name }
}
