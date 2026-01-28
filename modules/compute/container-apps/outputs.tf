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

