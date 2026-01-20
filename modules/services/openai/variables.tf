variable "name" {
  description = "The name of the Azure OpenAI resource"
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

variable "sku_name" {
  description = "The SKU name of the Cognitive Services Account"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "kind" {
  description = "The kind of Cognitive Services Account (default: OpenAI)"
  type        = string
  default     = null # null이면 루트 locals.defaults 사용
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed (default: false for security)"
  type        = bool
  default     = null # null이면 루트 security_defaults 사용
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
  description = "Map of Azure OpenAI deployments"
  type = map(object({
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
