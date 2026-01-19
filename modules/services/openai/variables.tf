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
  default     = "S0"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed"
  type        = bool
  default     = true
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

variable "deployments" {
  description = "Map of Azure OpenAI deployments"
  type = map(object({
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
