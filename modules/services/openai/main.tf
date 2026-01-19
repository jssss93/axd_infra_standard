resource "azurerm_cognitive_account" "openai" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.sku_name

  public_network_access_enabled = var.public_network_access_enabled

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags
}

# Azure OpenAI Deployments
resource "azurerm_cognitive_deployment" "this" {
  for_each = var.deployments

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.openai.id
  
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

  # scale 블록은 AzureRM 4.40에서 지원되지 않음
  # scale {
  #   type     = lookup(each.value.scale, "type", "Standard")
  #   capacity = lookup(each.value.scale, "capacity", null)
  #   family   = lookup(each.value.scale, "family", null)
  #   size     = lookup(each.value.scale, "size", null)
  #   tier     = lookup(each.value.scale, "tier", null)
  # }
}
