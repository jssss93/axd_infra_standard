variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "container_app_environment_name" {
  description = "The name of the Container App Environment"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "The subnet ID for the Container Apps Environment infrastructure (optional)"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics Workspace ID (optional, if not provided, one will be created)"
  type        = string
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "Name for the Log Analytics Workspace (optional, if not provided, will be generated)"
  type        = string
  default     = null
}

variable "log_analytics_workspace_suffix" {
  description = "Suffix for auto-generated Log Analytics Workspace name"
  type        = string
  default     = "laws"
}

variable "log_analytics_workspace_sku" {
  description = "SKU for the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Log Analytics Workspace retention in days"
  type        = number
  default     = 30
}

variable "container_apps" {
  description = "Map of Container App configurations"
  type = map(object({
    name          = optional(string)  # 명명규칙이 적용되면 자동 생성됨
    image         = string
    cpu           = optional(number, 0.25)
    memory        = optional(string, "0.5Gi")
    min_replicas  = optional(number, 0)
    max_replicas  = optional(number, 10)
    revision_mode = optional(string, "Single")
    env_vars      = optional(map(string), {})
    secrets = optional(list(object({
      name        = string
      secret_name = string
    })), [])
    ingress = optional(object({
      external_enabled = optional(bool, true)
      target_port      = number
      transport        = optional(string, "auto")
      traffic_weight = optional(object({
        percentage      = number
        latest_revision = optional(bool, true)
      }))
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "virtual_machines" {
  description = "Map of Virtual Machine configurations"
  type = map(object({
    name                          = string
    size                          = string
    subnet_id                     = string
    os_type                       = optional(string, "Linux")  # Linux or Windows
    admin_username                = string
    admin_password                 = optional(string)  # Required for Windows
    admin_ssh_key                 = optional(string)  # Required for Linux
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
    identity_type                          = optional(string)
    identity_ids                           = optional(list(string), [])
    boot_diagnostics_storage_account_uri    = optional(string)
    tags                                    = optional(map(string), {})
  }))
  default = {}
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to reference secrets from (optional)"
  type        = string
  default     = null
}

variable "key_vault_secrets" {
  description = "Map of Key Vault secret names to their resource IDs for Container Apps"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
