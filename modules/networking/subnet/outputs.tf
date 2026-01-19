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
