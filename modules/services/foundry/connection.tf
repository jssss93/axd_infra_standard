# Azure AI Foundry Project Connection to OpenAI
# Note: This uses azapi provider as azurerm doesn't support Foundry project connections yet
resource "azapi_resource" "foundry_project_openai_connection" {
  count = var.create_project && var.openai_resource_id != null ? 1 : 0

  type      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name      = var.openai_connection_name != null ? var.openai_connection_name : "openai-connection"
  parent_id = azurerm_ai_foundry_project.project[0].id

  body = jsonencode({
    properties = {
      resourceId = var.openai_resource_id
      authType   = "ManagedIdentity"
    }
  })

  depends_on = [
    azurerm_ai_foundry_project.project,
  ]
}
