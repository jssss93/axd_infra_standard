# Azure AI Foundry Hub
resource "azurerm_ai_foundry" "foundry" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  storage_account_id  = var.storage_account_id
  key_vault_id        = var.key_vault_id
  public_network_access = var.public_network_access_enabled ? "Enabled" : "Disabled"

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags
}

# Azure AI Foundry Project (optional)
resource "azurerm_ai_foundry_project" "project" {
  count = var.create_project ? 1 : 0

  name               = var.project_name != null ? var.project_name : "${var.name}-project"
  location           = var.location
  ai_services_hub_id = azurerm_ai_foundry.foundry.id

  dynamic "identity" {
    for_each = var.project_identity_type != null ? [1] : []
    content {
      type         = var.project_identity_type
      identity_ids = var.project_identity_ids
    }
  }

  tags = var.tags
}
