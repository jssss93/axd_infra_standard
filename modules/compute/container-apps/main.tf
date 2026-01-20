# Log Analytics Workspace (Container Apps Environment에 필요)
resource "azurerm_log_analytics_workspace" "this" {
  count               = var.log_analytics_workspace_id == null ? 1 : 0
  name                = var.log_analytics_workspace_name != null ? var.log_analytics_workspace_name : "${var.container_app_environment_name}-${var.log_analytics_workspace_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_retention_days

  tags = var.tags
}

# Container App Environment
resource "azurerm_container_app_environment" "this" {
  name                = var.container_app_environment_name
  location            = var.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_id = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : azurerm_log_analytics_workspace.this[0].id

  infrastructure_subnet_id = var.infrastructure_subnet_id

  tags = var.tags

  # infrastructure_resource_group_name은 읽기 전용 속성이므로 변경 무시
  # workload_profile은 Azure가 기본값(Consumption)으로 자동 설정하므로 변경 무시
  lifecycle {
    ignore_changes = [
      infrastructure_resource_group_name,
      workload_profile
    ]
  }
}

# Container Apps
resource "azurerm_container_app" "this" {
  for_each = var.container_apps

  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = lookup(each.value, "revision_mode", "Single")

  # Add SystemAssigned identity if Key Vault secrets are referenced
  dynamic "identity" {
    for_each = var.key_vault_id != null && length(var.key_vault_secrets) > 0 ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  # Key Vault secrets reference
  dynamic "secret" {
    for_each = var.key_vault_id != null && length(var.key_vault_secrets) > 0 ? var.key_vault_secrets : {}
    content {
      name                = secret.key
      key_vault_secret_id = secret.value
      identity            = "system"  # Use "system" for SystemAssigned identity
    }
  }

  template {
    min_replicas = lookup(each.value, "min_replicas", 0)
    max_replicas = lookup(each.value, "max_replicas", 10)

    container {
      name   = lookup(each.value, "container_name", null) != null ? each.value.container_name : each.key  # Container 블록의 name은 키를 사용 (또는 명시적으로 지정)
      image  = each.value.image
      cpu    = lookup(each.value, "cpu", 0.25)
      memory = lookup(each.value, "memory", "0.5Gi")

      dynamic "env" {
        for_each = lookup(each.value, "env_vars", {})
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = lookup(each.value, "secrets", [])
        content {
          name        = env.value.name
          secret_name = env.value.secret_name
        }
      }
    }
  }

  dynamic "ingress" {
    for_each = lookup(each.value, "ingress", null) != null ? [each.value.ingress] : []
    content {
      external_enabled = lookup(ingress.value, "external_enabled", true)
      target_port      = ingress.value.target_port
      transport        = lookup(ingress.value, "transport", "auto")

      dynamic "traffic_weight" {
        for_each = lookup(ingress.value, "traffic_weight", null) != null ? [ingress.value.traffic_weight] : [{
          percentage      = 100
          latest_revision = true
        }]
        content {
          percentage      = traffic_weight.value.percentage
          latest_revision = lookup(traffic_weight.value, "latest_revision", true)
        }
      }
    }
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}))

  # workload_profile_name은 Azure가 기본값(Consumption)으로 자동 설정하므로 변경 무시
  lifecycle {
    ignore_changes = [workload_profile_name]
  }
}

# Note: RBAC role assignment for Container Apps to access Key Vault should be done separately
# after Container Apps are created. Use Azure Portal or Azure CLI:
# az role assignment create --assignee <principal_id> --role "Key Vault Secrets User" --scope <key_vault_id>

# Virtual Machines
resource "azurerm_network_interface" "vm" {
  for_each = var.virtual_machines

  name                = "${each.value.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = lookup(each.value, "private_ip_address_allocation", "Dynamic")
    private_ip_address            = lookup(each.value, "private_ip_address", null)
    public_ip_address_id          = lookup(each.value, "public_ip_enabled", false) ? azurerm_public_ip.vm[each.key].id : null
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

resource "azurerm_public_ip" "vm" {
  for_each = {
    for k, v in var.virtual_machines : k => v
    if lookup(v, "public_ip_enabled", false)
  }

  name                = "${each.value.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = lookup(each.value, "public_ip_allocation_method", "Static")
  sku                 = lookup(each.value, "public_ip_sku", "Standard")

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = {
    for k, v in var.virtual_machines : k => v
    if lookup(v, "os_type", "Linux") == "Linux"
  }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = each.value.admin_ssh_key
  }

  os_disk {
    name                 = "${each.value.name}-os-disk"
    caching              = lookup(each.value, "os_disk_caching", "ReadWrite")
    storage_account_type = lookup(each.value, "os_disk_storage_account_type", "Premium_LRS")
    disk_size_gb         = lookup(each.value, "os_disk_size_gb", null)
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = lookup(each.value.source_image_reference, "version", "latest")
  }

  dynamic "identity" {
    for_each = lookup(each.value, "identity_type", null) != null ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = lookup(each.value, "identity_ids", [])
    }
  }

  boot_diagnostics {
    storage_account_uri = lookup(each.value, "boot_diagnostics_storage_account_uri", null)
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

resource "azurerm_windows_virtual_machine" "this" {
  for_each = {
    for k, v in var.virtual_machines : k => v
    if lookup(v, "os_type", "Linux") == "Windows"
  }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]

  os_disk {
    name                 = "${each.value.name}-os-disk"
    caching              = lookup(each.value, "os_disk_caching", "ReadWrite")
    storage_account_type = lookup(each.value, "os_disk_storage_account_type", "Premium_LRS")
    disk_size_gb         = lookup(each.value, "os_disk_size_gb", null)
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = lookup(each.value.source_image_reference, "version", "latest")
  }

  dynamic "identity" {
    for_each = lookup(each.value, "identity_type", null) != null ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = lookup(each.value, "identity_ids", [])
    }
  }

  boot_diagnostics {
    storage_account_uri = lookup(each.value, "boot_diagnostics_storage_account_uri", null)
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}
