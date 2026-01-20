# Virtual Network Module
module "vnet" {
  source = "./vnet"

  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers

  tags = var.tags
}

# Subnets Module
module "subnets" {
  source = "./subnet"

  resource_group_name  = var.resource_group_name
  virtual_network_name = module.vnet.name
  subnets              = var.subnets

  tags = var.tags
}

# Application Gateway Module
module "application_gateway" {
  count = var.application_gateway_enabled && var.application_gateway_config != null ? 1 : 0

  source = "./agw"

  name                          = var.application_gateway_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.application_gateway_subnet_id != null ? module.subnets.subnet_ids[var.application_gateway_subnet_id] : null
  sku_name                      = var.application_gateway_config.sku_name
  sku_tier                      = var.application_gateway_config.sku_tier
  capacity                      = var.application_gateway_config.capacity
  public_ip_enabled             = try(var.application_gateway_config.public_ip_enabled, true)
  public_ip_name                = try(var.application_gateway_config.public_ip_name, null)
  public_ip_allocation_method   = try(var.application_gateway_config.public_ip_allocation_method, "Static")
  public_ip_sku                 = try(var.application_gateway_config.public_ip_sku, "Standard")
  private_ip_address            = try(var.application_gateway_config.private_ip_address, null)
  private_ip_address_allocation = try(var.application_gateway_config.private_ip_address_allocation, "Static")
  frontend_ports                = var.application_gateway_config.frontend_ports
  backend_address_pools         = var.application_gateway_config.backend_address_pools
  backend_http_settings         = var.application_gateway_config.backend_http_settings
  http_listeners                = var.application_gateway_config.http_listeners
  request_routing_rules         = var.application_gateway_config.request_routing_rules
  ssl_certificates              = try(var.application_gateway_config.ssl_certificates, [])
  probes                        = try(var.application_gateway_config.probes, [])
  container_app_fqdns           = var.container_app_fqdns
  auto_connect_container_apps   = try(var.application_gateway_config.auto_connect_container_apps, true)

  tags = var.tags

  depends_on = [module.subnets]
}

# Networking PE Module (Private Endpoints + Private DNS Zones)
module "pe" {
  count = var.private_endpoints_enabled ? 1 : 0

  source = "./pe"

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_id             = module.vnet.id

  private_dns_zones = var.private_dns_zones != null ? {
    for k, v in var.private_dns_zones : k => merge(v, {
      virtual_network_ids = length(v.virtual_network_ids) == 0 ? [module.vnet.id] : v.virtual_network_ids
    })
  } : {}
  private_endpoints = var.private_endpoints

  tags = var.tags
}
