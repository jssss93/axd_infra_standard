variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# Key Vault variables
variable "key_vault_enabled" {
  description = "Whether to create Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_name" {
  description = "Key Vault name"
  type        = string
  default     = null
}

variable "key_vault_config" {
  description = "Key Vault configuration"
  type = object({
    tenant_id                      = optional(string)
    sku_name                       = optional(string, "standard")
    enabled_for_deployment        = optional(bool, false)
    enabled_for_disk_encryption    = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    rbac_authorization_enabled     = optional(bool, true)
    public_network_access_enabled  = optional(bool, true)
    purge_protection_enabled       = optional(bool, false)
    soft_delete_retention_days     = optional(number, 90)
    network_acls = optional(object({
      default_action             = string
      bypass                     = optional(string, "AzureServices")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), null)
    contacts = optional(list(object({
      email = string
      name  = optional(string)
      phone = optional(string)
    })), null)
    access_policies = optional(map(object({
      object_id               = string
      key_permissions         = optional(list(string), [])
      secret_permissions      = optional(list(string), [])
      certificate_permissions = optional(list(string), [])
      storage_permissions     = optional(list(string), [])
    })), {})
  })
  default = null
}

# Container Registry variables
variable "container_registry_enabled" {
  description = "Whether to create Container Registry"
  type        = bool
  default     = false
}

variable "container_registry_name" {
  description = "Container Registry name"
  type        = string
  default     = null
}

variable "container_registry_config" {
  description = "Container Registry configuration"
  type = object({
    sku                        = optional(string, "Basic")
    admin_enabled              = optional(bool, false)
    public_network_access_enabled = optional(bool, true)
    georeplications = optional(list(object({
      location                  = string
      regional_endpoint_enabled = optional(bool, true)
      zone_redundancy_enabled   = optional(bool, false)
      tags                      = optional(map(string), {})
    })), null)
    network_rule_set = optional(object({
      default_action = string
      ip_rules = optional(list(object({
        action   = string
        ip_range = string
      })), [])
      virtual_networks = optional(list(object({
        action    = string
        subnet_id = string
      })), [])
    }), null)
    retention_policy = optional(object({
      days    = number
      enabled = optional(bool, true)
    }), null)
    trust_policy = optional(object({
      enabled = bool
    }), null)
    encryption = optional(object({
      enabled            = bool
      key_vault_key_id   = optional(string)
      identity_client_id = optional(string)
    }), null)
    identity_type = optional(string, "SystemAssigned")
    identity_ids  = optional(list(string), [])
  })
  default = null
}

# Cosmos DB variables
variable "cosmos_db_enabled" {
  description = "Whether to create Cosmos DB"
  type        = bool
  default     = false
}

variable "cosmos_db_name" {
  description = "Cosmos DB name"
  type        = string
  default     = null
}

variable "cosmos_db_config" {
  description = "Cosmos DB configuration"
  type = object({
    offer_type                      = optional(string, "Standard")
    kind                            = optional(string, "GlobalDocumentDB")
    consistency_level               = optional(string, "Session")
    max_interval_in_seconds         = optional(number, 5)
    max_staleness_prefix           = optional(number, 100)
    capabilities                    = optional(list(string), null)
    geo_locations = list(object({
      location          = string
      failover_priority = number
      zone_redundant    = optional(bool, false)
    }))
    backup = optional(object({
      type                = string
      interval_in_minutes = optional(number)
      retention_in_hours  = optional(number)
      storage_redundancy  = optional(string)
    }), null)
    cors_rule = optional(object({
      allowed_origins    = list(string)
      allowed_methods    = optional(list(string), [])
      allowed_headers    = optional(list(string), [])
      exposed_headers    = optional(list(string), [])
      max_age_in_seconds = optional(number)
    }), null)
    is_virtual_network_filter_enabled = optional(bool, false)
    virtual_network_rules = optional(list(object({
      id                                   = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
    ip_range_filter                   = optional(string, null)
    public_network_access_enabled     = optional(bool, true)
    enable_automatic_failover         = optional(bool, false)
    enable_multiple_write_locations  = optional(bool, false)
    access_key_metadata_writes_enabled = optional(bool, true)
    local_authentication_disabled     = optional(bool, false)
    identity_type                     = optional(string, null)
    identity_ids                      = optional(list(string), [])
    databases = optional(map(object({
      name         = string
      throughput   = optional(number)
      autoscale_settings = optional(object({
        max_throughput = number
      }))
      tags = optional(map(string), {})
    })), {})
    containers = optional(map(object({
      name              = string
      database_name     = string
      partition_key_path = string
      throughput        = optional(number)
      autoscale_settings = optional(object({
        max_throughput = number
      }))
      indexing_policy = optional(object({
        indexing_mode  = optional(string, "consistent")
        included_paths  = optional(list(string), [])
        excluded_paths  = optional(list(string), [])
      }))
      unique_keys = optional(list(object({
        paths = list(string)
      })), [])
      tags = optional(map(string), {})
    })), {})
  })
  default = null
}

# PostgreSQL variables
variable "postgresql_enabled" {
  description = "Whether to create PostgreSQL"
  type        = bool
  default     = false
}

variable "postgresql_name" {
  description = "PostgreSQL name"
  type        = string
  default     = null
}

variable "postgresql_config" {
  description = "PostgreSQL configuration"
  type = object({
    server_version      = optional(string, "14")
    administrator_login    = string
    administrator_password  = string
    sku_name             = optional(string, "B_Standard_B1ms")
    storage_mb           = optional(number, 32768)
    backup_retention_days = optional(number, 7)
    geo_redundant_backup_enabled = optional(bool, false)
    public_network_access_enabled = optional(bool, true)
    maintenance_window = optional(object({
      day_of_week  = number
      start_hour   = number
      start_minute = optional(number, 0)
    }), null)
    high_availability = optional(object({
      mode                      = string
      standby_availability_zone = optional(string)
    }), null)
    identity_type        = optional(string, null)
    identity_ids         = optional(list(string), [])
    firewall_rules = optional(map(object({
      name             = string
      start_ip_address = string
      end_ip_address   = string
    })), {})
    databases = optional(map(object({
      name      = string
      charset   = optional(string, "UTF8")
      collation = optional(string, "en_US.utf8")
      tags      = optional(map(string), {})
    })), {})
    server_configurations = optional(map(string), {})
  })
  default = null
}
