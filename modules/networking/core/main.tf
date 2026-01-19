# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space

  dns_servers = var.dns_servers

  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = lookup(each.value, "name", null) != null ? each.value.name : "${each.key}-sbn"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  # Optional configurations
  service_endpoints           = lookup(each.value, "service_endpoints", null)
  service_endpoint_policy_ids = lookup(each.value, "service_endpoint_policy_ids", null)

  # Delegation block
  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = lookup(delegation.value.service_delegation, "actions", null)
      }
    }
  }
}

# Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "network_security_group_id", null) != null
  }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value.network_security_group_id
}

# Route Table Association
resource "azurerm_subnet_route_table_association" "this" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "route_table_id", null) != null
  }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = each.value.route_table_id
}

# Application Gateway (optional)
resource "azurerm_public_ip" "agw" {
  count = var.application_gateway_enabled && var.application_gateway_config != null && lookup(var.application_gateway_config, "public_ip_enabled", true) ? 1 : 0

  name                = lookup(var.application_gateway_config, "public_ip_name", null) != null ? var.application_gateway_config.public_ip_name : "${var.application_gateway_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = lookup(var.application_gateway_config, "public_ip_allocation_method", "Static")
  sku                 = lookup(var.application_gateway_config, "public_ip_sku", "Standard")

  tags = var.tags
}

resource "azurerm_application_gateway" "this" {
  count = var.application_gateway_enabled && var.application_gateway_config != null ? 1 : 0

  name                = var.application_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.application_gateway_config.sku_name
    tier     = var.application_gateway_config.sku_tier
    capacity = var.application_gateway_config.capacity
  }

  gateway_ip_configuration {
    name      = "${var.application_gateway_name}-ip-config"
    subnet_id = var.application_gateway_subnet_id != null ? azurerm_subnet.this[var.application_gateway_subnet_id].id : null
  }

  dynamic "frontend_port" {
    for_each = var.application_gateway_config.frontend_ports
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = lookup(var.application_gateway_config, "public_ip_enabled", true) && length(azurerm_public_ip.agw) > 0 ? [1] : []
    content {
      name                 = "${var.application_gateway_name}-feip-public"
      public_ip_address_id = azurerm_public_ip.agw[0].id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = lookup(var.application_gateway_config, "private_ip_address", null) != null ? [1] : []
    content {
      name                          = "${var.application_gateway_name}-feip-private"
      subnet_id                     = var.application_gateway_subnet_id != null ? azurerm_subnet.this[var.application_gateway_subnet_id].id : null
      private_ip_address            = var.application_gateway_config.private_ip_address
      private_ip_address_allocation = lookup(var.application_gateway_config, "private_ip_address_allocation", "Static")
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.application_gateway_config.backend_address_pools
    content {
      name         = backend_address_pool.value.name
      fqdns        = length(lookup(backend_address_pool.value, "fqdns", [])) > 0 ? backend_address_pool.value.fqdns : (
        # Container Apps FQDN이 자동으로 추가됨 (auto_connect_container_apps가 true인 경우)
        lookup(var.application_gateway_config, "auto_connect_container_apps", true) && length(var.container_app_fqdns) > 0 ? values(var.container_app_fqdns) : lookup(backend_address_pool.value, "fqdns", [])
      )
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.application_gateway_config.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = lookup(backend_http_settings.value, "cookie_based_affinity", "Disabled")
      path                                = lookup(backend_http_settings.value, "path", "/")
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = lookup(backend_http_settings.value, "request_timeout", 20)
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      host_name                           = lookup(backend_http_settings.value, "host_name", null)
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "host_name", null) == null && length(var.container_app_fqdns) > 0 ? true : lookup(backend_http_settings.value, "pick_host_name_from_backend_address", false)
    }
  }

  dynamic "http_listener" {
    for_each = var.application_gateway_config.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = lookup(http_listener.value, "host_name", null)
      ssl_certificate_name           = lookup(http_listener.value, "ssl_certificate_name", null)
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.application_gateway_config.request_routing_rules
    content {
      name                        = request_routing_rule.value.name
      rule_type                   = request_routing_rule.value.rule_type
      http_listener_name          = request_routing_rule.value.http_listener_name
      priority                    = lookup(request_routing_rule.value, "priority", 100 + (request_routing_rule.key * 10))
      backend_address_pool_name   = lookup(request_routing_rule.value, "backend_address_pool_name", null)
      backend_http_settings_name  = lookup(request_routing_rule.value, "backend_http_settings_name", null)
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
      rewrite_rule_set_name       = lookup(request_routing_rule.value, "rewrite_rule_set_name", null)
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
    }
  }

  dynamic "ssl_certificate" {
    for_each = lookup(var.application_gateway_config, "ssl_certificates", [])
    content {
      name                = ssl_certificate.value.name
      data                = lookup(ssl_certificate.value, "data", null)
      password            = lookup(ssl_certificate.value, "password", null)
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }

  dynamic "probe" {
    for_each = lookup(var.application_gateway_config, "probes", [])
    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = lookup(probe.value, "host", null)
      interval                                  = lookup(probe.value, "interval", 30)
      timeout                                   = lookup(probe.value, "timeout", 30)
      unhealthy_threshold                       = lookup(probe.value, "unhealthy_threshold", 3)
      minimum_servers                           = lookup(probe.value, "minimum_servers", 0)
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", false)
    }
  }

  tags = var.tags
}
