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
    storage_account_id                            = optional(string, null)
    storage_account_name                          = optional(string, null)
    storage_account_tier                          = optional(string, null)
    storage_account_replication_type              = optional(string, null)
    storage_account_public_network_access_enabled = optional(bool, null)
    storage_account_name_suffix                   = optional(string, null)
    public_network_access_enabled                 = optional(bool, null)
    identity_type                                 = optional(string, null)
    identity_ids                                  = optional(list(string), [])
    create_project                                = optional(bool, false)
    project_name                                  = optional(string, null)
    project_identity_type                         = optional(string, null)
    project_identity_ids                          = optional(list(string), [])
    deployments = optional(map(object({
      name                   = string
      model_name             = string
      model_format           = optional(string)
      model_version          = optional(string)
      rai_policy_name        = optional(string)
      version_upgrade_option = optional(string)
      scale = object({
        name     = optional(string)
        type     = optional(string)
        capacity = optional(number)
        family   = optional(string)
        size     = optional(string)
        tier     = optional(string)
      })
    })), {})
    project_deployments = optional(map(object({
      name                   = string
      model_name             = string
      model_format           = optional(string)
      model_version          = optional(string)
      rai_policy_name        = optional(string)
      version_upgrade_option = optional(string)
      scale = object({
        name     = optional(string)
        type     = optional(string)
        capacity = optional(number)
        family   = optional(string)
        size     = optional(string)
        tier     = optional(string)
      })
    })), {})
    cognitive_account_sku_name     = optional(string, null)
    cognitive_account_kind         = optional(string, null)
    cognitive_account_name_suffix  = optional(string, null)
    default_model_format           = optional(string, null)
    default_version_upgrade_option = optional(string, null)
    default_deployment_sku_type    = optional(string, null)
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
    sku_name                      = optional(string, null)
    kind                          = optional(string, null)
    public_network_access_enabled = optional(bool, null)
    identity_type                 = optional(string, null)
    identity_ids                  = optional(list(string), [])
    deployments = optional(map(object({
      name                   = string
      model_name             = string
      model_format           = optional(string)
      model_version          = optional(string)
      rai_policy_name        = optional(string)
      version_upgrade_option = optional(string)
      scale = object({
        type     = optional(string)
        capacity = optional(number)
        family   = optional(string)
        size     = optional(string)
        tier     = optional(string)
      })
    })), {})
    default_model_format           = optional(string, null)
    default_version_upgrade_option = optional(string, null)
    default_deployment_sku_type    = optional(string, null)
  })
  default = null
}
