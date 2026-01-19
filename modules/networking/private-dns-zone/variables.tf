variable "name" {
  description = "The name of the Private DNS Zone (e.g., privatelink.vaultcore.azure.net)"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "virtual_network_ids" {
  description = "List of Virtual Network IDs to link to this Private DNS Zone"
  type        = list(string)
  default     = null
}

variable "virtual_network_link_name" {
  description = "The name of the Virtual Network Link (optional, auto-generated if not provided)"
  type        = string
  default     = null
}

variable "registration_enabled" {
  description = "Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled?"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
