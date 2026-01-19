resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  public_network_access_enabled = var.public_network_access_enabled

  dynamic "georeplications" {
    for_each = var.georeplications != null ? var.georeplications : []
    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = lookup(georeplications.value, "regional_endpoint_enabled", true)
      zone_redundancy_enabled   = lookup(georeplications.value, "zone_redundancy_enabled", false)
      tags                      = lookup(georeplications.value, "tags", {})
    }
  }

  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = lookup(network_rule_set.value, "ip_rules", [])
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }

      # virtual_network는 AzureRM 4.40에서 network_rule_set 내부에서 지원되지 않을 수 있음
      # dynamic "virtual_network" {
      #   for_each = lookup(network_rule_set.value, "virtual_networks", [])
      #   content {
      #     action    = virtual_network.value.action
      #     subnet_id = virtual_network.value.subnet_id
      #   }
      # }
    }
  }

  # retention_policy와 trust_policy는 AzureRM 4.40에서 지원되지 않을 수 있음
  # dynamic "retention_policy" {
  #   for_each = var.retention_policy != null ? [var.retention_policy] : []
  #   content {
  #     days    = retention_policy.value.days
  #     enabled = lookup(retention_policy.value, "enabled", true)
  #   }
  # }

  # dynamic "trust_policy" {
  #   for_each = var.trust_policy != null ? [var.trust_policy] : []
  #   content {
  #     enabled = trust_policy.value.enabled
  #   }
  # }

  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      # enabled는 AzureRM 4.40에서 지원되지 않을 수 있음
      key_vault_key_id   = lookup(encryption.value, "key_vault_key_id", null)
      identity_client_id = lookup(encryption.value, "identity_client_id", null)
    }
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  tags = var.tags
}
