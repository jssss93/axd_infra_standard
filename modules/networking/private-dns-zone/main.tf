# Private DNS Zone
resource "azurerm_private_dns_zone" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Private DNS Zone Virtual Network Link (optional)
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.virtual_network_ids != null ? toset(var.virtual_network_ids) : []

  name                  = var.virtual_network_link_name != null ? var.virtual_network_link_name : "${var.name}-link-${substr(each.value, length(each.value) - 8, -1)}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = each.value
  registration_enabled   = var.registration_enabled

  tags = var.tags
}
