variable "name" {
  description = "The name of the Container Registry"
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

variable "sku" {
  description = "The SKU name of the Container Registry"
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the Container Registry (default: false for security)"
  type        = bool
  default     = null # null이면 루트 security_defaults 사용
}

variable "georeplications" {
  description = "A list of Azure locations where the Container Registry should be geo-replicated"
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, true)
    zone_redundancy_enabled   = optional(bool, false)
    tags                      = optional(map(string), {})
  }))
  default = null
}

variable "network_rule_set" {
  description = "Network rule set for the Container Registry"
  type = object({
    default_action = string
    ip_rules = optional(list(object({
      action   = string
      ip_range = string
    })), [])
    virtual_networks = optional(list(object({
      action    = string
      subnet_id = string
    })), [])
  })
  default = null
}

variable "retention_policy" {
  description = "A retention_policy block"
  type = object({
    days    = number
    enabled = optional(bool, true)
  })
  default = null
}

variable "trust_policy" {
  description = "A trust_policy block"
  type = object({
    enabled = bool
  })
  default = null
}

variable "encryption" {
  description = "An encryption block"
  type = object({
    enabled            = bool
    key_vault_key_id   = optional(string)
    identity_client_id = optional(string)
  })
  default = null
}

variable "identity_type" {
  description = "The type of Managed Identity which should be assigned"
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "A list of User Managed Identity IDs to be assigned"
  type        = list(string)
  default     = []
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
