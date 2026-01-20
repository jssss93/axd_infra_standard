# Azure AI Foundry OpenAI Deployments (Project Level Only)
# Project 레벨에만 Account를 생성하고, 그 안에 모든 모델 배포
resource "azurerm_cognitive_deployment" "project_deployments" {
  for_each = var.create_project && length(var.project_deployments) > 0 ? var.project_deployments : {}

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.project[0].id

  model {
    format  = lookup(each.value, "model_format", var.default_model_format != null ? var.default_model_format : "OpenAI")
    name    = each.value.model_name
    version = lookup(each.value, "model_version", null)
  }

  rai_policy_name        = lookup(each.value, "rai_policy_name", null)
  version_upgrade_option = lookup(each.value, "version_upgrade_option", var.default_version_upgrade_option != null ? var.default_version_upgrade_option : "OnceNewDefaultVersionAvailable")

  sku {
    name     = lookup(each.value.scale, "name", lookup(each.value.scale, "type", var.default_deployment_sku_type != null ? var.default_deployment_sku_type : "Standard"))
    capacity = lookup(each.value.scale, "capacity", null)
  }

  depends_on = [
    azurerm_ai_foundry.foundry,
    azurerm_ai_foundry_project.project,
    azurerm_cognitive_account.project,
  ]
}
