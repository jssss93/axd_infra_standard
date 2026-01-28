# Container Apps Outputs
output "container_app_fqdns" {
  description = "Map of Container App FQDNs"
  value       = module.container_apps.container_app_fqdns
}

output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value       = module.container_apps.container_app_environment_id
}

output "container_app_environment_name" {
  description = "The name of the Container App Environment"
  value       = module.container_apps.container_app_environment_name
}

output "container_app_ids" {
  description = "Map of Container App IDs"
  value       = module.container_apps.container_app_ids
}

# Virtual Machine Outputs
output "virtual_machine_ids" {
  description = "Map of Virtual Machine IDs"
  value       = length(module.virtual_machines) > 0 ? module.virtual_machines[0].virtual_machine_ids : {}
}

output "virtual_machine_names" {
  description = "Map of Virtual Machine names"
  value       = length(module.virtual_machines) > 0 ? module.virtual_machines[0].virtual_machine_names : {}
}

output "virtual_machine_private_ip_addresses" {
  description = "Map of Virtual Machine private IP addresses"
  value       = length(module.virtual_machines) > 0 ? module.virtual_machines[0].virtual_machine_private_ip_addresses : {}
}

output "virtual_machine_public_ip_addresses" {
  description = "Map of Virtual Machine public IP addresses"
  value       = length(module.virtual_machines) > 0 ? module.virtual_machines[0].virtual_machine_public_ip_addresses : {}
}

