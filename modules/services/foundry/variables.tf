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
  description = "The ID of the Storage Account to use for the Foundry hub"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to use for the Foundry hub"
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Foundry hub"
  type        = bool
  default     = false
}

variable "identity_type" {
  description = "The type of Managed Identity which should be assigned to the Foundry hub"
  type        = string
  default     = "SystemAssigned"
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

variable "deployments" {
  description = "Map of OpenAI deployments to create within the Foundry project"
  type = map(object({
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
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
