# Microsoft Foundry AI Services
# Note: Foundry services are typically provisioned through Azure Portal or Azure CLI
# This module provides a structure for Foundry-related resources

# Foundry AI Project (if available via Terraform provider)
# Note: As of now, Foundry services may need to be provisioned via Azure CLI or Portal
# This is a placeholder structure that can be extended when Terraform provider support is available

resource "azurerm_cognitive_account" "foundry" {
  count = var.create_cognitive_account ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = var.cognitive_account_kind
  sku_name            = var.cognitive_account_sku

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

# Foundry AI Services Configuration
# Note: Actual Foundry service provisioning may require Azure CLI or Portal
# This module structure can be extended when Terraform provider support is available

locals {
  foundry_services = var.foundry_services != null ? var.foundry_services : {}
}
