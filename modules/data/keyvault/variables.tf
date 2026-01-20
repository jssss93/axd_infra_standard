variable "name" {
  description = "The name of the Key Vault"
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

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault"
  type        = string
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault"
  type        = string
  default     = "standard"
}

variable "enabled_for_deployment" {
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault"
  type        = bool
  default     = false
}

variable "rbac_authorization_enabled" {
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for this Key Vault (default: false for security)"
  type        = bool
  default     = null # null이면 루트 security_defaults 사용
}

variable "purge_protection_enabled" {
  description = "Is Purge Protection enabled for this Key Vault"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted"
  type        = number
  default     = 90
}

variable "network_acls" {
  description = "A network_acls block"
  type = object({
    default_action             = string
    bypass                     = optional(string, "AzureServices")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "contacts" {
  description = "A list of contact objects"
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = null
}

variable "access_policies" {
  description = "A map of access policies (only used when RBAC is disabled)"
  type = map(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
