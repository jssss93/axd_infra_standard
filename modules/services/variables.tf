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

variable "key_vault_id" {
  description = "The ID of the Key Vault (created in data module)"
  type        = string
  default     = null
}

# AI Foundry variables
variable "foundry_enabled" {
  description = "Whether to create AI Foundry resources"
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
    storage_account_id         = optional(string, null)
    storage_account_name       = optional(string, null)
    storage_account_tier       = optional(string, "Standard")
    storage_account_replication_type = optional(string, "LRS")
    storage_account_public_network_access_enabled = optional(bool, false)
    public_network_access_enabled = optional(bool, false)
    identity_type              = optional(string, "SystemAssigned")
    identity_ids               = optional(list(string), [])
    create_project             = optional(bool, false)
    project_name               = optional(string, null)
    project_identity_type      = optional(string, null)
    project_identity_ids       = optional(list(string), [])
    deployments = optional(map(object({
      name                 = string
      model_name           = string
      model_format         = optional(string, "OpenAI")
      model_version        = optional(string)
      rai_policy_name      = optional(string)
      version_upgrade_option = optional(string, "AutoUpgrade")
      scale = object({
        name     = optional(string)
        type     = optional(string, "Standard")
        capacity = optional(number)
        family   = optional(string)
        size     = optional(string)
        tier     = optional(string)
      })
    })), {})
  })
  default = null
}

# OpenAI variables
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
    sku_name                    = optional(string, "S0")
    public_network_access_enabled = optional(bool, true)
    identity_type               = optional(string, null)
    identity_ids                = optional(list(string), [])
    deployments = optional(map(object({
      name                 = string
      model_name           = string
      model_format         = optional(string, "OpenAI")
      model_version        = optional(string)
      rai_policy_name      = optional(string)
      version_upgrade_option = optional(string, "AutoUpgrade")
      scale = object({
        type     = optional(string, "Standard")
        capacity = optional(number)
        family   = optional(string)
        size     = optional(string)
        tier     = optional(string)
      })
    })), {})
  })
  default = null
}
