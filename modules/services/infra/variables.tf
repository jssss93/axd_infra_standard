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

# Container Registry Variables
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
    sku                          = optional(string, "Basic")
    admin_enabled                = optional(bool, false)
    public_network_access_enabled = optional(bool, true)
    georeplications              = optional(list(any), null)
    network_rule_set             = optional(any, null)
    retention_policy             = optional(any, null)
    trust_policy                 = optional(any, null)
    encryption                   = optional(any, null)
    identity_type                = optional(string, "SystemAssigned")
    identity_ids                  = optional(list(string), [])
  })
  default = null
}

# Key Vault Variables
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
    enabled_for_deployment         = optional(bool, false)
    enabled_for_disk_encryption   = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    rbac_authorization_enabled     = optional(bool, true)
    public_network_access_enabled = optional(bool, true)
    purge_protection_enabled       = optional(bool, false)
    soft_delete_retention_days    = optional(number, 90)
    network_acls                  = optional(any, null)
    contacts                      = optional(list(any), null)
    access_policies               = optional(map(any), {})
  })
  default = null
}

# Cosmos DB Variables
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
    capabilities                   = optional(list(string), null)
    geo_locations                   = list(any)
    backup                          = optional(any, null)
    cors_rule                       = optional(any, null)
    is_virtual_network_filter_enabled = optional(bool, false)
    virtual_network_rules          = optional(list(any), [])
    ip_range_filter                = optional(any, null)
    public_network_access_enabled  = optional(bool, true)
    access_key_metadata_writes_enabled = optional(bool, true)
    local_authentication_disabled   = optional(bool, false)
    identity_type                  = optional(string, null)
    identity_ids                   = optional(list(string), [])
    databases                      = optional(map(any), {})
    containers                     = optional(map(any), {})
  })
  default = null
}

# PostgreSQL Variables
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
    server_version                  = optional(string, "14")
    administrator_login            = string
    administrator_password          = string
    sku_name                        = optional(string, "B_Standard_B1ms")
    storage_mb                      = optional(number, 32768)
    backup_retention_days           = optional(number, 7)
    geo_redundant_backup_enabled   = optional(bool, false)
    public_network_access_enabled   = optional(bool, true)
    maintenance_window              = optional(any, null)
    high_availability              = optional(any, null)
    identity_type                   = optional(string, null)
    identity_ids                    = optional(list(string), [])
    firewall_rules                 = optional(map(any), {})
    databases                      = optional(map(any), {})
    server_configurations          = optional(map(string), {})
  })
  default = null
}

# AI Foundry Variables
variable "foundry_enabled" {
  description = "Whether to create AI Foundry"
  type        = bool
  default     = false
}

variable "foundry_name" {
  description = "AI Foundry name"
  type        = string
  default     = null
}

variable "foundry_config" {
  description = "AI Foundry configuration"
  type = object({
    # Storage Account 설정
    storage_account_id                        = optional(string, null)
    storage_account_name                      = optional(string, null)
    storage_account_tier                      = optional(string, "Standard")
    storage_account_replication_type          = optional(string, "LRS")
    storage_account_public_network_access_enabled = optional(bool, false)
    
    # Foundry Hub 설정
    public_network_access_enabled  = optional(bool, false)
    identity_type                   = optional(string, "SystemAssigned")
    identity_ids                    = optional(list(string), [])
    
    # Foundry Project 설정
    create_project                 = optional(bool, false)
    project_name                   = optional(string, null)
    project_identity_type          = optional(string, null)
    project_identity_ids           = optional(list(string), [])
    
    # Foundry Project OpenAI Connection 설정
    openai_resource_id             = optional(string, null)
    openai_connection_name         = optional(string, null)
    
    # Legacy fields (deprecated, kept for backward compatibility)
    create_cognitive_account      = optional(bool, true)
    cognitive_account_kind        = optional(string, "OpenAI")
    cognitive_account_sku         = optional(string, "S0")
    foundry_services              = optional(map(any), null)
  })
  default = null
}

# OpenAI Variables
variable "openai_enabled" {
  description = "Whether to create OpenAI"
  type        = bool
  default     = false
}

variable "openai_name" {
  description = "OpenAI name"
  type        = string
  default     = null
}

variable "openai_config" {
  description = "OpenAI configuration"
  type = object({
    sku_name                        = optional(string, "S0")
    public_network_access_enabled   = optional(bool, true)
    identity_type                   = optional(string, null)
    identity_ids                    = optional(list(string), [])
    deployments                     = optional(map(any), {})
  })
  default = null
}
