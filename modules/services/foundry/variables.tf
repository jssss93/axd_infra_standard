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

variable "openai_resource_id" {
  description = "The resource ID of the Azure OpenAI resource to connect to the Foundry project"
  type        = string
  default     = null
}

variable "openai_connection_name" {
  description = "The name of the OpenAI connection in the Foundry project"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
