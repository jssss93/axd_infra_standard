variable "name" {
  description = "The name of the Cosmos DB Account"
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

variable "offer_type" {
  description = "Specifies the Offer Type to use for this CosmosDB Account"
  type        = string
  default     = "Standard"
}

variable "kind" {
  description = "Specifies the Kind of CosmosDB to create"
  type        = string
  default     = "GlobalDocumentDB"
}

variable "consistency_level" {
  description = "The Consistency Level to use for this CosmosDB Account"
  type        = string
  default     = "Session"
}

variable "max_interval_in_seconds" {
  description = "When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated"
  type        = number
  default     = 5
}

variable "max_staleness_prefix" {
  description = "When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated"
  type        = number
  default     = 100
}

variable "capabilities" {
  description = "List of capabilities to enable for this Cosmos DB account"
  type        = list(string)
  default     = null
}

variable "geo_locations" {
  description = "Specifies a geo_location resource, used to define where data should be replicated with the failover_priority 0 specifying the primary location"
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, false)
  }))
}

variable "backup" {
  description = "A backup block"
  type = object({
    type                = string
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
    storage_redundancy  = optional(string)
  })
  default = null
}

variable "cors_rule" {
  description = "A cors_rule block"
  type = object({
    allowed_origins    = list(string)
    allowed_methods    = optional(list(string), [])
    allowed_headers    = optional(list(string), [])
    exposed_headers    = optional(list(string), [])
    max_age_in_seconds = optional(number)
  })
  default = null
}

variable "is_virtual_network_filter_enabled" {
  description = "Enables virtual network filtering for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "virtual_network_rules" {
  description = "Specifies a virtual_network_rules resource"
  type = list(object({
    id                                   = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default = []
}

variable "ip_range_filter" {
  description = "A list of ip_range_filter values"
  type        = list(string)
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this CosmosDB account"
  type        = bool
  default     = true
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "enable_multiple_write_locations" {
  description = "Enable multiple write locations for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "access_key_metadata_writes_enabled" {
  description = "Is write operations on metadata resources (databases, containers, throughput) via account keys enabled"
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Disable local authentication and ensure only Microsoft Entra authentication can be used"
  type        = bool
  default     = false
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

variable "databases" {
  description = "Map of Cosmos DB SQL databases"
  type = map(object({
    name         = string
    throughput   = optional(number)
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "containers" {
  description = "Map of Cosmos DB SQL containers"
  type = map(object({
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
  }))
  default = {}
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
