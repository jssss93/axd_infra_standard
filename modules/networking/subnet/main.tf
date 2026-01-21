# Subnets
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = try(each.value.name, null) != null ? each.value.name : "${each.key}-sbn"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = each.value.address_prefixes

  # Optional configurations
  service_endpoints           = try(each.value.service_endpoints, null)
  service_endpoint_policy_ids = try(each.value.service_endpoint_policy_ids, null)
  
  # Private Endpoint network policies (agw subnet은 제외하고 기본값 Disabled)
  # "Disabled" = Private Endpoint 네트워크 정책 비활성화 (Private Endpoint 사용 가능)
  # "Enabled" = Private Endpoint 네트워크 정책 활성화
  private_endpoint_network_policies = try(
    each.value.private_endpoint_network_policies_enabled != null ? (
      each.value.private_endpoint_network_policies_enabled ? "Enabled" : "Disabled"
    ) : null,
    each.key == "agw" ? "Enabled" : "Disabled"  # agw는 Enabled, 나머지는 Disabled
  )

  # Delegation block
  dynamic "delegation" {
    for_each = try(each.value.delegation, null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = try(delegation.value.service_delegation.actions, null)
      }
    }
  }
}

# Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = {
    for k, v in var.subnets : k => v
    if try(v.network_security_group_id, null) != null
  }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value.network_security_group_id
}

# Route Table Association
resource "azurerm_subnet_route_table_association" "this" {
  for_each = {
    for k, v in var.subnets : k => v
    if try(v.route_table_id, null) != null
  }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = each.value.route_table_id
}
