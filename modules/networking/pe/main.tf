# Private DNS Zones
resource "azurerm_private_dns_zone" "this" {
  for_each = var.private_dns_zones

  name                = each.value.name
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Private DNS Zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = {
    for link in flatten([
      for zone_key, zone in var.private_dns_zones : [
        for vnet_id in zone.virtual_network_ids : {
          key           = "${zone_key}-${substr(vnet_id, length(vnet_id) - 8, -1)}"
          zone_key      = zone_key
          vnet_id       = vnet_id
          link_name     = lookup(zone, "virtual_network_link_name", null)
          registration_enabled = lookup(zone, "registration_enabled", false)
        }
      ]
    ]) : link.key => link
  }

  name                  = each.value.link_name != null ? each.value.link_name : "${var.private_dns_zones[each.value.zone_key].name}-link-${substr(each.value.vnet_id, length(each.value.vnet_id) - 8, -1)}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone_key].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = each.value.registration_enabled

  tags = var.tags
}

# Private Endpoints
resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = lookup(each.value, "private_service_connection_name", null) != null ? each.value.private_service_connection_name : "${each.value.name}-connection"
    private_connection_resource_id = each.value.private_connection_resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = lookup(each.value, "is_manual_connection", false)
    request_message                = lookup(each.value, "request_message", null)
  }

  dynamic "private_dns_zone_group" {
    for_each = lookup(each.value, "private_dns_zone_key", null) != null && contains(keys(azurerm_private_dns_zone.this), each.value.private_dns_zone_key) ? [1] : []
    content {
      name                 = lookup(each.value, "private_dns_zone_group_name", null) != null ? each.value.private_dns_zone_group_name : "${each.value.name}-dns-zone-group"
      private_dns_zone_ids = [azurerm_private_dns_zone.this[each.value.private_dns_zone_key].id]
    }
  }

  tags = var.tags
}
