variable "name" {
  description = "The name of the Azure AI Foundry hub"
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

variable "storage_account_id" {
  description = "The ID of the Storage Account to use for the Foundry hub (optional, if not provided, one will be created)"
  type        = string
  default     = null
}

variable "storage_account_name" {
  description = "The name of the Storage Account to create (if storage_account_id is not provided)"
  type        = string
  default     = null
}

variable "storage_account_tier" {
  description = "The tier of the Storage Account"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "storage_account_replication_type" {
  description = "The replication type of the Storage Account"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "storage_account_public_network_access_enabled" {
  description = "Whether public network access is enabled for the Storage Account (default: false for security)"
  type        = bool
  default     = null # null이면 루트 security_defaults 사용
}

variable "storage_account_name_suffix" {
  description = "Suffix for Storage Account name (default: 'sa')"
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to use for the Foundry hub (optional, but recommended)"
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Foundry hub and Cognitive Services Account (default: false for security)"
  type        = bool
  default     = null # null이면 루트 security_defaults 사용
}

variable "cognitive_account_sku_name" {
  description = "The SKU name for the Cognitive Services Account (used for model deployments)"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "cognitive_account_kind" {
  description = "The kind of Cognitive Services Account (default: OpenAI)"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "cognitive_account_name_suffix" {
  description = "Suffix for Cognitive Account name (default: 'cog')"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The type of Managed Identity which should be assigned to the Foundry hub"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "identity_ids" {
  description = "A list of User Managed Identity IDs to be assigned"
  type        = list(string)
  default     = []
}

variable "create_project" {
  description = "Whether to create a Foundry project"
  type        = bool
  default     = false
}

variable "project_name" {
  description = "The name of the Foundry project (if create_project is true)"
  type        = string
  default     = null
}

variable "project_identity_type" {
  description = "The type of Managed Identity which should be assigned to the Foundry project"
  type        = string
  default     = null
}

variable "project_identity_ids" {
  description = "A list of User Managed Identity IDs to be assigned to the project"
  type        = list(string)
  default     = []
}

variable "default_model_format" {
  description = "Default model format for deployments"
  type        = string
  default     = null # null이면 "OpenAI" 사용
}

variable "default_version_upgrade_option" {
  description = "Default version upgrade option for deployments"
  type        = string
  default     = null # null이면 "OnceNewDefaultVersionAvailable" 사용
}

variable "default_deployment_sku_type" {
  description = "Default SKU type for deployments"
  type        = string
  default     = null # null이면 "Standard" 사용
}

variable "deployments" {
  description = "Map of OpenAI deployments to create within the Foundry Hub (Cognitive Services Account)"
  type = map(object({
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
  }))
  default = {}
}

variable "project_deployments" {
  description = "Map of OpenAI deployments to create within the Foundry Project (separate Cognitive Services Account)"
  type = map(object({
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
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
