# Data source for existing Storage Account (if name is provided but ID is not)
data "azurerm_storage_account" "foundry" {
  count = var.storage_account_id == null && var.storage_account_name != null ? 1 : 0

  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Storage Account for Foundry (if not provided and not found via data source)
resource "azurerm_storage_account" "foundry" {
  count = var.storage_account_id == null && (var.storage_account_name == null || length(data.azurerm_storage_account.foundry) == 0) ? 1 : 0

  name                     = var.storage_account_name != null ? var.storage_account_name : "${replace(var.name, "-", "")}sa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  
  # Public network access 설정 (기본값: false - AXD 정책 요구사항)
  public_network_access_enabled = var.storage_account_public_network_access_enabled

  tags = var.tags
}

# Azure AI Foundry Hub
resource "azurerm_ai_foundry" "foundry" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  storage_account_id  = var.storage_account_id != null ? var.storage_account_id : (
    length(data.azurerm_storage_account.foundry) > 0 ? data.azurerm_storage_account.foundry[0].id : azurerm_storage_account.foundry[0].id
  )
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
