resource "azurerm_cosmosdb_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type != null ? var.offer_type : "Standard"
  kind                = var.kind != null ? var.kind : "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = var.consistency_level != null ? var.consistency_level : "Session"
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }

  dynamic "capabilities" {
    for_each = var.capabilities != null ? var.capabilities : []
    content {
      name = capabilities.value
    }
  }

  dynamic "geo_location" {
    for_each = var.geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = try(geo_location.value.zone_redundant, false)
    }
  }

  dynamic "backup" {
    for_each = var.backup != null ? [var.backup] : []
    content {
      type                = backup.value.type
      interval_in_minutes = try(backup.value.interval_in_minutes, null)
      retention_in_hours  = try(backup.value.retention_in_hours, null)
      storage_redundancy  = try(backup.value.storage_redundancy, null)
    }
  }

  dynamic "cors_rule" {
    for_each = var.cors_rule != null ? [var.cors_rule] : []
    content {
      allowed_origins    = cors_rule.value.allowed_origins
      allowed_methods    = try(cors_rule.value.allowed_methods, [])
      allowed_headers    = try(cors_rule.value.allowed_headers, [])
      exposed_headers    = try(cors_rule.value.exposed_headers, [])
      max_age_in_seconds = try(cors_rule.value.max_age_in_seconds, null)
    }
  }

  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules != null ? var.virtual_network_rules : []
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = try(virtual_network_rule.value.ignore_missing_vnet_service_endpoint, false)
    }
  }

  ip_range_filter = var.ip_range_filter != null ? toset(var.ip_range_filter) : null

  public_network_access_enabled = var.public_network_access_enabled != null ? var.public_network_access_enabled : false

  # enable_automatic_failover와 enable_multiple_write_locations는 AzureRM 4.40에서 제거됨
  # enable_automatic_failover = var.enable_automatic_failover
  # enable_multiple_write_locations = var.enable_multiple_write_locations

  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled
  local_authentication_disabled      = var.local_authentication_disabled

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags
}

# Cosmos DB Database
resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = var.databases

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = try(each.value.throughput, null)

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  # tags는 Cosmos DB SQL Database에서 지원되지 않음
  # tags = merge(var.tags, try(each.value.tags, {}))
}

# Cosmos DB Containers
resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = var.containers

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = each.value.database_name
  partition_key_paths = [each.value.partition_key_path] # AzureRM 4.40에서는 partition_key_paths (복수형) 사용
  throughput          = try(each.value.throughput, null)

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  dynamic "indexing_policy" {
    for_each = try(each.value.indexing_policy, null) != null ? [each.value.indexing_policy] : []
    content {
      indexing_mode = try(indexing_policy.value.indexing_mode, var.default_indexing_mode != null ? var.default_indexing_mode : "consistent")

      dynamic "included_path" {
        for_each = try(indexing_policy.value.included_paths, [])
        content {
          path = included_path.value
        }
      }

      dynamic "excluded_path" {
        for_each = try(indexing_policy.value.excluded_paths, [])
        content {
          path = excluded_path.value
        }
      }
    }
  }

  dynamic "unique_key" {
    for_each = try(each.value.unique_keys, [])
    content {
      paths = unique_key.value.paths
    }
  }

  # tags는 Cosmos DB SQL Container에서 지원되지 않음
  # tags = merge(var.tags, try(each.value.tags, {}))
}
