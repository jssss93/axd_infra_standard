variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "subnets" {
  description = "Map of subnet configurations. Name is optional and will be auto-generated if not provided."
  type = map(object({
    name                        = optional(string)
    address_prefixes            = list(string)
    network_security_group_id   = optional(string)
    route_table_id              = optional(string)
    service_endpoints           = optional(list(string))
    service_endpoint_policy_ids = optional(list(string))
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
