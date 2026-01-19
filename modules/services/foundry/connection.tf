# Azure AI Foundry OpenAI Deployments
# Deploy OpenAI models within the Foundry Hub (not project)
# Note: Deployments are created at the Foundry Hub level, not project level
resource "azurerm_cognitive_deployment" "foundry_deployments" {
  for_each = length(var.deployments) > 0 ? var.deployments : {}

  name                 = each.value.name
  cognitive_account_id = azurerm_ai_foundry.foundry.id
  
  model {
    format  = lookup(each.value, "model_format", "OpenAI")
    name    = each.value.model_name
    version = lookup(each.value, "model_version", null)
  }

  rai_policy_name = lookup(each.value, "rai_policy_name", null)
  version_upgrade_option = lookup(each.value, "version_upgrade_option", "AutoUpgrade")

  sku {
    name     = lookup(each.value.scale, "name", lookup(each.value.scale, "type", "Standard"))
    capacity = lookup(each.value.scale, "capacity", null)
  }

  depends_on = [
    azurerm_ai_foundry.foundry,
  ]
}
