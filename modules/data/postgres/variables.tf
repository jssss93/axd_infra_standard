variable "name" {
  description = "The name of the PostgreSQL Flexible Server"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "server_version" {
  description = "The version of PostgreSQL to use"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "administrator_login" {
  description = "The Administrator Login for the PostgreSQL Flexible Server"
  type        = string
}

variable "administrator_password" {
  description = "The Administrator Password for the PostgreSQL Flexible Server"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "The SKU Name for the PostgreSQL Flexible Server"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "storage_mb" {
  description = "The max storage allowed for the PostgreSQL Flexible Server"
  type        = number
  default     = null # null이면 루트 locals.defaults 사용
}

variable "backup_retention_days" {
  description = "Backup retention days for the server"
  type        = number
  default     = null # null이면 루트 locals.defaults 사용
}

variable "geo_redundant_backup_enabled" {
  description = "Enable Geo-redundant backups"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Is public network access enabled? (default: false for security)"
  type        = bool
  default     = null # null이면 루트 security_defaults 사용
}

variable "maintenance_window" {
  description = "A maintenance_window block"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = optional(number, 0)
  })
  default = null
}

variable "high_availability" {
  description = "A high_availability block"
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null
}

variable "identity_type" {
  description = "The type of Managed Identity which should be assigned"
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "A list of User Managed Identity IDs to be assigned"
  type        = list(string)
  default     = []
}

variable "firewall_rules" {
  description = "Map of firewall rules"
  type = map(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "default_charset" {
  description = "Default charset for PostgreSQL databases"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "default_collation" {
  description = "Default collation for PostgreSQL databases"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "databases" {
  description = "Map of PostgreSQL databases"
  type = map(object({
    name      = string
    charset   = optional(string)
    collation = optional(string)
    tags      = optional(map(string), {})
  }))
  default = {}
}

variable "server_configurations" {
  description = "Map of server configuration parameters"
  type        = map(string)
  default     = {}
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to store secrets (optional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
