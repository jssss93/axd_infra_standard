resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.server_version != null ? var.server_version : "14"
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku_name              = var.sku_name != null ? var.sku_name : "B_Standard_B1ms"
  storage_mb            = var.storage_mb != null ? var.storage_mb : 32768
  backup_retention_days = var.backup_retention_days != null ? var.backup_retention_days : 7

  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  public_network_access_enabled = var.public_network_access_enabled != null ? var.public_network_access_enabled : false

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = lookup(maintenance_window.value, "start_minute", 0)
    }
  }

  dynamic "high_availability" {
    for_each = var.high_availability != null ? [var.high_availability] : []
    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = lookup(high_availability.value, "standby_availability_zone", null)
    }
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags

  # zone은 읽기 전용 속성이므로 변경 무시
  lifecycle {
    ignore_changes = [zone]
  }
}

# PostgreSQL Firewall Rules
resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  for_each = var.firewall_rules

  name             = each.value.name
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# PostgreSQL Databases
resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each = var.databases

  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = lookup(each.value, "charset", var.default_charset != null ? var.default_charset : "UTF8")
  collation = lookup(each.value, "collation", var.default_collation != null ? var.default_collation : "en_US.utf8")

  # tags는 PostgreSQL Flexible Server Database에서 지원되지 않음
  # tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# PostgreSQL Flexible Server Configuration
resource "azurerm_postgresql_flexible_server_configuration" "this" {
  for_each = var.server_configurations

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = each.value
}
