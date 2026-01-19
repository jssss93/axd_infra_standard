variable "name" {
  description = "The name of the Foundry AI resource"
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

variable "create_cognitive_account" {
  description = "Whether to create a Cognitive Services account for Foundry"
  type        = bool
  default     = true
}

variable "cognitive_account_kind" {
  description = "The kind of Cognitive Services Account"
  type        = string
  default     = "OpenAI"
}

variable "cognitive_account_sku" {
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

variable "foundry_services" {
  description = "Map of Foundry AI services configuration (placeholder for future implementation)"
  type        = map(any)
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
