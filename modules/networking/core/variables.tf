# Network Variables
variable "name" {
  description = "The name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network"
  type        = string
}

variable "location" {
  description = "The Azure region where the virtual network will be created"
  type        = string
}

variable "address_space" {
  description = "The address space that is used by the virtual network"
  type        = list(string)
}

variable "dns_servers" {
  description = "List of IP addresses of DNS servers"
  type        = list(string)
  default     = []
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

# Application Gateway Variables
variable "application_gateway_enabled" {
  description = "Whether to create an Application Gateway"
  type        = bool
  default     = false
}

variable "application_gateway_name" {
  description = "The name of the Application Gateway"
  type        = string
  default     = null
}

variable "application_gateway_subnet_id" {
  description = "The subnet key for the Application Gateway (e.g., 'appgw')"
  type        = string
  default     = null
}

variable "application_gateway_config" {
  description = "Application Gateway configuration"
  type = object({
    sku_name                      = string
    sku_tier                      = string
    capacity                      = number
    public_ip_enabled             = optional(bool, true)
    public_ip_name                = optional(string)
    public_ip_allocation_method   = optional(string, "Static")
    public_ip_sku                 = optional(string, "Standard")
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Static")
    frontend_ports = list(object({
      name = string
      port = number
    }))
    backend_address_pools = list(object({
      name         = string
      fqdns        = optional(list(string))
      ip_addresses = optional(list(string))
    }))
    backend_http_settings = list(object({
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
    http_listeners = list(object({
      name                           = string
      frontend_ip_configuration_name = string
      frontend_port_name             = string
      protocol                       = string
      host_name                      = optional(string)
      ssl_certificate_name           = optional(string)
    }))
    request_routing_rules = list(object({
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
    ssl_certificates = optional(list(object({
      name                = string
      data                = optional(string)
      password            = optional(string)
      key_vault_secret_id = optional(string)
    })), [])
    probes = optional(list(object({
      name                                      = string
      protocol                                  = string
      path                                      = string
      host                                      = optional(string)
      interval                                  = optional(number, 30)
      timeout                                   = optional(number, 30)
      unhealthy_threshold                       = optional(number, 3)
      minimum_servers                           = optional(number, 0)
      pick_host_name_from_backend_http_settings = optional(bool, false)
    })), [])
    auto_connect_container_apps = optional(bool, true)
  })
  default = null
}

# Container Apps FQDNs (optional, for AGW backend pool auto-configuration)
variable "container_app_fqdns" {
  description = "Map of Container App FQDNs for Application Gateway backend pool auto-configuration"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
