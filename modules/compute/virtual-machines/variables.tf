variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "virtual_machines" {
  description = "Map of Virtual Machine configurations. subnet_id should be subnet ID"
  type = map(object({
    name                          = string
    size                          = string
    subnet_id                     = string                    # Subnet ID
    os_type                       = optional(string, "Linux") # Linux or Windows
    admin_username                = string
    admin_password                = optional(string) # Required for Windows
    admin_ssh_key                 = optional(string) # Required for Linux
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    public_ip_enabled             = optional(bool, false)
    public_ip_allocation_method   = optional(string, "Static")
    public_ip_sku                 = optional(string, "Standard")
    os_disk_caching               = optional(string, "ReadWrite")
    os_disk_storage_account_type  = optional(string, "Premium_LRS")
    os_disk_size_gb               = optional(number)
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = optional(string, "latest")
    })
    identity_type                        = optional(string)
    identity_ids                         = optional(list(string), [])
    boot_diagnostics_storage_account_uri = optional(string)
    tags                                 = optional(map(string), {})
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
