# Application Gateway Public IP (optional)
resource "azurerm_public_ip" "agw" {
  count = var.public_ip_enabled ? 1 : 0

  name                = var.public_ip_name != null ? var.public_ip_name : "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  tags = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "${var.name}-ip-config"
    subnet_id = var.subnet_id
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.public_ip_enabled && length(azurerm_public_ip.agw) > 0 ? [1] : []
    content {
      name                 = "${var.name}-feip-public"
      public_ip_address_id = azurerm_public_ip.agw[0].id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_ip_address != null ? [1] : []
    content {
      name                          = "${var.name}-feip-private"
      subnet_id                     = var.subnet_id
      private_ip_address            = var.private_ip_address
      private_ip_address_allocation = var.private_ip_address_allocation
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name = backend_address_pool.value.name
      fqdns = length(try(backend_address_pool.value.fqdns, [])) > 0 ? backend_address_pool.value.fqdns : (
        var.auto_connect_container_apps && length(var.container_app_fqdns) > 0 ? values(var.container_app_fqdns) : try(backend_address_pool.value.fqdns, [])
      )
      ip_addresses = try(backend_address_pool.value.ip_addresses, null)
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = try(backend_http_settings.value.cookie_based_affinity, "Disabled")
      path                                = try(backend_http_settings.value.path, "/")
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = try(backend_http_settings.value.request_timeout, 20)
      probe_name                          = try(backend_http_settings.value.probe_name, null)
      host_name                           = try(backend_http_settings.value.host_name, null)
      pick_host_name_from_backend_address = try(backend_http_settings.value.host_name, null) == null && length(var.container_app_fqdns) > 0 ? true : try(backend_http_settings.value.pick_host_name_from_backend_address, false)
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = try(http_listener.value.host_name, null)
      ssl_certificate_name           = try(http_listener.value.ssl_certificate_name, null)
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                        = request_routing_rule.value.name
      rule_type                   = request_routing_rule.value.rule_type
      http_listener_name          = request_routing_rule.value.http_listener_name
      priority                    = try(request_routing_rule.value.priority, 100 + (request_routing_rule.key * 10))
      backend_address_pool_name   = try(request_routing_rule.value.backend_address_pool_name, null)
      backend_http_settings_name  = try(request_routing_rule.value.backend_http_settings_name, null)
      redirect_configuration_name = try(request_routing_rule.value.redirect_configuration_name, null)
      rewrite_rule_set_name       = try(request_routing_rule.value.rewrite_rule_set_name, null)
      url_path_map_name           = try(request_routing_rule.value.url_path_map_name, null)
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = try(ssl_certificate.value.data, null)
      password            = try(ssl_certificate.value.password, null)
      key_vault_secret_id = try(ssl_certificate.value.key_vault_secret_id, null)
    }
  }

  dynamic "probe" {
    for_each = var.probes
    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      host                                      = try(probe.value.host, null)
      interval                                  = try(probe.value.interval, 30)
      timeout                                   = try(probe.value.timeout, 30)
      unhealthy_threshold                       = try(probe.value.unhealthy_threshold, 3)
      minimum_servers                           = try(probe.value.minimum_servers, 0)
      pick_host_name_from_backend_http_settings = try(probe.value.pick_host_name_from_backend_http_settings, false)
    }
  }

  tags = var.tags
}
