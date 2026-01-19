variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the Virtual Network for Private DNS Zone links"
  type        = string
}

variable "private_dns_zones" {
  description = "Map of Private DNS Zone configurations"
  type = map(object({
    name                      = string
    virtual_network_ids        = list(string)
    virtual_network_link_name  = optional(string)
    registration_enabled       = optional(bool, false)
  }))
  default = {}
}

variable "private_endpoints" {
  description = "Map of Private Endpoint configurations"
  type = map(object({
    name                          = string
    subnet_id                     = string
    private_connection_resource_id = string
    subresource_names              = list(string)
    is_manual_connection           = optional(bool, false)
    request_message                = optional(string)
    private_service_connection_name = optional(string)
    private_dns_zone_key            = optional(string)  # Key to reference private_dns_zones map
    private_dns_zone_group_name    = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
