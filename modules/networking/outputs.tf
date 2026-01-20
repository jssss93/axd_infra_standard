# Virtual Network Outputs
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = module.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = module.vnet.address_space
}

# Subnets Outputs
output "subnet_ids" {
  description = "Map of subnet keys to subnet IDs"
  value       = module.subnets.subnet_ids
}

output "subnet_names" {
  description = "Map of subnet keys to subnet names"
  value       = module.subnets.subnet_names
}

output "subnets" {
  description = "Map of subnet keys to subnet objects"
  value       = module.subnets.subnets
}

# Application Gateway Outputs
output "application_gateway_id" {
  description = "The ID of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(module.application_gateway) > 0 ? module.application_gateway[0].id : null
}

output "application_gateway_name" {
  description = "The name of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(module.application_gateway) > 0 ? module.application_gateway[0].name : null
}

output "application_gateway_public_ip" {
  description = "The public IP address of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(module.application_gateway) > 0 ? module.application_gateway[0].public_ip_address : null
}

output "application_gateway_public_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = var.application_gateway_enabled && var.application_gateway_config != null && length(module.application_gateway) > 0 ? module.application_gateway[0].public_ip_address : null
}

# Private Endpoints Outputs
output "private_dns_zone_ids" {
  description = "Map of Private DNS Zone keys to their IDs"
  value       = var.private_endpoints_enabled && length(module.pe) > 0 ? module.pe[0].private_dns_zone_ids : {}
}

output "private_endpoint_ids" {
  description = "Map of Private Endpoint keys to their IDs"
  value       = var.private_endpoints_enabled && length(module.pe) > 0 ? module.pe[0].private_endpoint_ids : {}
}
