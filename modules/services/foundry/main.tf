# Data source for existing Storage Account (if name is provided but ID is not)
# 기존 리소스를 찾지 못하면 data source가 실패하므로, try()로 감싸거나 제거
# 대신 storage_account_name이 있으면 바로 resource를 생성하도록 함
data "azurerm_storage_account" "foundry" {
  count = var.storage_account_id == null && var.storage_account_name != null ? 1 : 0

  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Storage Account for Foundry (if not provided and not found via data source)
# storage_account_name이 있지만 data source에서 찾지 못한 경우도 새로 생성
resource "azurerm_storage_account" "foundry" {
  count = var.storage_account_id == null && (
    var.storage_account_name == null || 
    (length(data.azurerm_storage_account.foundry) == 0 && var.storage_account_name != null)
  ) ? 1 : 0

  name                     = var.storage_account_name != null ? var.storage_account_name : "${replace(var.name, "-", "")}${var.storage_account_name_suffix != null ? var.storage_account_name_suffix : "sa"}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier != null ? var.storage_account_tier : "Standard"
  account_replication_type = var.storage_account_replication_type != null ? var.storage_account_replication_type : "LRS"

  # Public network access 설정 (기본값: false - 보안 정책)
  public_network_access_enabled = var.storage_account_public_network_access_enabled != null ? var.storage_account_public_network_access_enabled : false

  # System Assigned Identity - always enabled
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Azure AI Foundry Hub
resource "azurerm_ai_foundry" "foundry" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  storage_account_id = var.storage_account_id != null ? var.storage_account_id : (
    length(data.azurerm_storage_account.foundry) > 0 ? data.azurerm_storage_account.foundry[0].id : azurerm_storage_account.foundry[0].id
  )
  key_vault_id          = var.key_vault_id
  public_network_access = (var.public_network_access_enabled != null ? var.public_network_access_enabled : false) ? "Enabled" : "Disabled"

  dynamic "identity" {
    for_each = (var.identity_type != null ? var.identity_type : "SystemAssigned") != null ? [1] : []
    content {
      type         = var.identity_type != null ? var.identity_type : "SystemAssigned"
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags
}

# Cognitive Services Account for Foundry Project (Project 레벨에만 생성)
# Hub 레벨의 Account는 생성하지 않고, Project에만 Account 생성
resource "azurerm_cognitive_account" "project" {
  count = var.create_project && length(var.project_deployments) > 0 ? 1 : 0

  name                = "${var.project_name != null ? var.project_name : "${var.name}-project"}-${var.cognitive_account_name_suffix != null ? var.cognitive_account_name_suffix : "cog"}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.cognitive_account_kind != null ? var.cognitive_account_kind : "OpenAI"
  sku_name            = var.cognitive_account_sku_name != null ? var.cognitive_account_sku_name : "S0"

  public_network_access_enabled = var.public_network_access_enabled != null ? var.public_network_access_enabled : false

  dynamic "identity" {
    for_each = var.project_identity_type != null ? [var.project_identity_type] : (var.identity_type != null ? [var.identity_type] : [])
    content {
      type         = identity.value
      identity_ids = var.project_identity_type != null ? var.project_identity_ids : var.identity_ids
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_ai_foundry.foundry,
    azurerm_ai_foundry_project.project,
  ]
}

# Azure AI Foundry Project (optional)
resource "azurerm_ai_foundry_project" "project" {
  count = var.create_project ? 1 : 0

  name               = var.project_name != null ? var.project_name : "${var.name}-project"
  location           = var.location
  ai_services_hub_id = azurerm_ai_foundry.foundry.id

  # Project requires identity - use project_identity_type if provided, otherwise use identity_type, otherwise SystemAssigned
  identity {
    type         = var.project_identity_type != null ? var.project_identity_type : (var.identity_type != null ? var.identity_type : "SystemAssigned")
    identity_ids = var.project_identity_type != null ? var.project_identity_ids : var.identity_ids
  }

  tags = var.tags
}
