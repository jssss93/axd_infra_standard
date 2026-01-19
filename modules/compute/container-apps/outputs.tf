output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : azurerm_log_analytics_workspace.this[0].id
}

output "container_app_environment_id" {
  description = "The ID of the Container App Environment"
  value       = azurerm_container_app_environment.this.id
}

output "container_app_environment_name" {
  description = "The name of the Container App Environment"
  value       = azurerm_container_app_environment.this.name
}

output "container_app_ids" {
  description = "Map of Container App IDs"
  value       = { for k, v in azurerm_container_app.this : k => v.id }
}

output "container_app_fqdns" {
  description = "Map of Container App FQDNs"
  value       = { for k, v in azurerm_container_app.this : k => v.latest_revision_fqdn }
}

output "container_apps" {
  description = "Map of Container App objects"
  value       = azurerm_container_app.this
}

# Virtual Machine Outputs
output "virtual_machine_ids" {
  description = "Map of Virtual Machine keys to their IDs (Linux and Windows combined)"
  value = merge(
    { for k, v in azurerm_linux_virtual_machine.this : k => v.id },
    { for k, v in azurerm_windows_virtual_machine.this : k => v.id }
  )
}

output "virtual_machine_names" {
  description = "Map of Virtual Machine keys to their names"
  value = merge(
    { for k, v in azurerm_linux_virtual_machine.this : k => v.name },
    { for k, v in azurerm_windows_virtual_machine.this : k => v.name }
  )
}

output "virtual_machine_private_ip_addresses" {
  description = "Map of Virtual Machine keys to their private IP addresses"
  value = { for k, v in azurerm_network_interface.vm : k => v.ip_configuration[0].private_ip_address }
}

output "virtual_machine_public_ip_addresses" {
  description = "Map of Virtual Machine keys to their public IP addresses (if enabled)"
  value = {
    for k, v in azurerm_public_ip.vm : k => v.ip_address
  }
}
