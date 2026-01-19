variable "name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the Application Gateway will be created"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for the Application Gateway"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Application Gateway"
  type        = string
}

variable "sku_tier" {
  description = "The SKU tier of the Application Gateway"
  type        = string
}

variable "capacity" {
  description = "The capacity of the Application Gateway"
  type        = number
}

variable "public_ip_enabled" {
  description = "Whether to create a public IP for the Application Gateway"
  type        = bool
  default     = true
}

variable "public_ip_name" {
  description = "The name of the public IP"
  type        = string
  default     = null
}

variable "public_ip_allocation_method" {
  description = "The allocation method for the public IP"
  type        = string
  default     = "Static"
}

variable "public_ip_sku" {
  description = "The SKU of the public IP"
  type        = string
  default     = "Standard"
}

variable "private_ip_address" {
  description = "The private IP address for the Application Gateway"
  type        = string
  default     = null
}

variable "private_ip_address_allocation" {
  description = "The allocation method for the private IP address"
  type        = string
  default     = "Static"
}

variable "frontend_ports" {
  description = "List of frontend ports"
  type = list(object({
    name = string
    port = number
  }))
}

variable "backend_address_pools" {
  description = "List of backend address pools"
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
}

variable "backend_http_settings" {
  description = "List of backend HTTP settings"
  type = list(object({
    name                                = string
    cookie_based_affinity               = optional(string, "Disabled")
    path                                = optional(string, "/")
    port                                = number
    protocol                            = string
    request_timeout                     = optional(number, 20)
    probe_name                          = optional(string)
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, false)
  }))
}

variable "http_listeners" {
  description = "List of HTTP listeners"
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string
    host_name                      = optional(string)
    ssl_certificate_name           = optional(string)
  }))
}

variable "request_routing_rules" {
  description = "List of request routing rules"
  type = list(object({
    name                        = string
    rule_type                   = string
    http_listener_name          = string
    priority                    = optional(number)
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    url_path_map_name           = optional(string)
  }))
}

variable "ssl_certificates" {
  description = "List of SSL certificates"
  type = list(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "probes" {
  description = "List of probes"
  type = list(object({
    name                                      = string
    protocol                                  = string
    path                                      = string
    host                                      = optional(string)
    interval                                  = optional(number, 30)
    timeout                                   = optional(number, 30)
    unhealthy_threshold                       = optional(number, 3)
    minimum_servers                           = optional(number, 0)
    pick_host_name_from_backend_http_settings = optional(bool, false)
  }))
  default = []
}

variable "container_app_fqdns" {
  description = "Map of Container App FQDNs for Application Gateway backend pool auto-configuration"
  type        = map(string)
  default     = {}
}

variable "auto_connect_container_apps" {
  description = "Whether to automatically connect Container Apps FQDNs to backend pools"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
