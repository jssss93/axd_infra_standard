# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space

  dns_servers = var.dns_servers

  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = lookup(each.value, "name", null) != null ? each.value.name : "${each.key}-sbn" # name이 없으면 키 기반으로 생성 (fallback)
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  # Optional configurations
  service_endpoints           = lookup(each.value, "service_endpoints", null)
  service_endpoint_policy_ids = lookup(each.value, "service_endpoint_policy_ids", null)

  # Delegation block
  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = lookup(delegation.value.service_delegation, "actions", null)
      }
    }
  }
}

# Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "network_security_group_id", null) != null
  }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value.network_security_group_id
}

# Route Table Association
resource "azurerm_subnet_route_table_association" "this" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "route_table_id", null) != null
  }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = each.value.route_table_id
}
