output "virtual_machine_ids" {
  description = "Map of Virtual Machine IDs"
  value = merge(
    { for k, v in azurerm_linux_virtual_machine.this : k => v.id },
    { for k, v in azurerm_windows_virtual_machine.this : k => v.id }
  )
}

output "virtual_machine_names" {
  description = "Map of Virtual Machine names"
  value = merge(
    { for k, v in azurerm_linux_virtual_machine.this : k => v.name },
    { for k, v in azurerm_windows_virtual_machine.this : k => v.name }
  )
}

output "virtual_machine_private_ip_addresses" {
  description = "Map of Virtual Machine private IP addresses"
  value = {
    for k, v in azurerm_network_interface.vm : k => v.ip_configuration[0].private_ip_address
  }
}

output "virtual_machine_public_ip_addresses" {
  description = "Map of Virtual Machine public IP addresses"
  value = {
    for k, v in azurerm_public_ip.vm : k => v.ip_address
  }
}

output "network_interface_ids" {
  description = "Map of Network Interface IDs"
  value = {
    for k, v in azurerm_network_interface.vm : k => v.id
  }
}

output "public_ip_ids" {
  description = "Map of Public IP IDs"
  value = {
    for k, v in azurerm_public_ip.vm : k => v.id
  }
}
