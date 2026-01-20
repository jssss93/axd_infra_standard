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
  description = "Map of Virtual Machine keys to their IDs"
  value       = module.container_apps.virtual_machine_ids
}

output "virtual_machine_names" {
  description = "Map of Virtual Machine keys to their names"
  value       = module.container_apps.virtual_machine_names
}

