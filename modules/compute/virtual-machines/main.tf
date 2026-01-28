# Network Interface for Virtual Machines
resource "azurerm_network_interface" "vm" {
  for_each = var.virtual_machines

  name                = "${each.value.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = try(each.value.private_ip_address_allocation, "Dynamic")
    private_ip_address            = try(each.value.private_ip_address, null)
    public_ip_address_id          = try(each.value.public_ip_enabled, false) ? azurerm_public_ip.vm[each.key].id : null
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

# Public IP for Virtual Machines (optional)
resource "azurerm_public_ip" "vm" {
  for_each = {
    for k, v in var.virtual_machines : k => v
    if try(v.public_ip_enabled, false)
  }

  name                = "${each.value.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = try(each.value.public_ip_allocation_method, "Static")
  sku                 = try(each.value.public_ip_sku, "Standard")

  tags = merge(var.tags, try(each.value.tags, {}))
}

# Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "this" {
  for_each = {
    for k, v in var.virtual_machines : k => v
    if try(v.os_type, "Linux") == "Linux"
  }

  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = each.value.size
  admin_username        = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = each.value.admin_ssh_key
  }

  os_disk {
    name                 = "${each.value.name}-os-disk"
    caching              = try(each.value.os_disk_caching, "ReadWrite")
    storage_account_type = try(each.value.os_disk_storage_account_type, "Premium_LRS")
    disk_size_gb         = try(each.value.os_disk_size_gb, null)
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = try(each.value.source_image_reference.version, "latest")
  }

  dynamic "identity" {
    for_each = try(each.value.identity_type, null) != null ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = try(each.value.identity_ids, [])
    }
  }

  boot_diagnostics {
    storage_account_uri = try(each.value.boot_diagnostics_storage_account_uri, null)
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

# Windows Virtual Machines
resource "azurerm_windows_virtual_machine" "this" {
  for_each = {
    for k, v in var.virtual_machines : k => v
    if try(v.os_type, "Linux") == "Windows"
  }

  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = each.value.size
  admin_username        = each.value.admin_username
  admin_password        = each.value.admin_password
  network_interface_ids = [azurerm_network_interface.vm[each.key].id]

  os_disk {
    name                 = "${each.value.name}-os-disk"
    caching              = try(each.value.os_disk_caching, "ReadWrite")
    storage_account_type = try(each.value.os_disk_storage_account_type, "Premium_LRS")
    disk_size_gb         = try(each.value.os_disk_size_gb, null)
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = try(each.value.source_image_reference.version, "latest")
  }

  dynamic "identity" {
    for_each = try(each.value.identity_type, null) != null ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = try(each.value.identity_ids, [])
    }
  }

  boot_diagnostics {
    storage_account_uri = try(each.value.boot_diagnostics_storage_account_uri, null)
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}
