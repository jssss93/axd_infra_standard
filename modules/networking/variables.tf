variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# Virtual Network variables
variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "dns_servers" {
  description = "List of DNS servers IP addresses"
  type        = list(string)
  default     = []
}

# Subnets variables
variable "subnets" {
  description = "Map of subnet configurations. Key is used as asset_management for naming convention. If name is not provided, it will be auto-generated using naming convention."
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

# Application Gateway variables
variable "application_gateway_enabled" {
  description = "Whether to create Application Gateway"
  type        = bool
  default     = false
}

variable "application_gateway_name" {
  description = "Application Gateway name"
  type        = string
  default     = null
}

variable "application_gateway_subnet_id" {
  description = "Application Gateway용 서브넷 키 이름"
  type        = string
  default     = null
}

variable "application_gateway_config" {
  description = "Application Gateway 설정"
  type = object({
    sku_name                      = optional(string, "Standard_v2")
    sku_tier                      = optional(string, "Standard_v2")
    capacity                      = optional(number, 2)
    public_ip_enabled             = optional(bool, true)
    public_ip_name                = optional(string)
    public_ip_allocation_method   = optional(string, "Static")
    public_ip_sku                 = optional(string, "Standard")
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Static")
    auto_connect_container_apps   = optional(bool, true)
    frontend_ports = optional(list(object({
      name = string
      port = number
      })), [
      {
        name = "http"
        port = 80
      },
      {
        name = "https"
        port = 443
      }
    ])
    backend_address_pools = optional(list(object({
      name         = string
      fqdns        = optional(list(string))
      ip_addresses = optional(list(string))
    })), [])
    backend_http_settings = optional(list(object({
      name                                = string
      cookie_based_affinity               = optional(string, "Disabled")
      path                                = optional(string, "/")
      port                                = number
      protocol                            = string
      request_timeout                     = optional(number, 20)
      probe_name                          = optional(string)
      host_name                           = optional(string)
      pick_host_name_from_backend_address = optional(bool, false)
    })), [])
    http_listeners = optional(list(object({
      name                           = string
      frontend_ip_configuration_name = string
      frontend_port_name             = string
      protocol                       = string
      host_name                      = optional(string)
      ssl_certificate_name           = optional(string)
    })), [])
    request_routing_rules = optional(list(object({
      name                        = string
      rule_type                   = string
      http_listener_name          = string
      priority                    = optional(number)
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      url_path_map_name           = optional(string)
    })), [])
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
  })
  default = null
}

variable "container_app_fqdns" {
  description = "Map of Container App FQDNs for Application Gateway backend pool auto-configuration"
  type        = map(string)
  default     = {}
}

# Private Endpoints variables
variable "private_endpoints_enabled" {
  description = "Whether to create Private Endpoints for PaaS services"
  type        = bool
  default     = false
}

variable "private_dns_zones" {
  description = "Map of Private DNS Zone configurations"
  type = map(object({
    name                      = string
    virtual_network_ids       = list(string)
    virtual_network_link_name = optional(string)
    registration_enabled      = optional(bool, false)
  }))
  default = {}
}

variable "private_endpoints" {
  description = "Map of Private Endpoint configurations"
  type = map(object({
    name                            = string
    subnet_id                       = string
    private_connection_resource_id  = string
    subresource_names               = list(string)
    is_manual_connection            = optional(bool, false)
    request_message                 = optional(string)
    private_service_connection_name = optional(string)
    private_dns_zone_key            = optional(string)
    private_dns_zone_group_name     = optional(string)
  }))
  default = {}
}
