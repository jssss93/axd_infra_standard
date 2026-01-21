# ============================================================================
# 환경별 변수 정의 (Dev 환경)
# ============================================================================
# 주의: Terraform 모듈 구조상 환경별 variables.tf에 모든 변수를 정의해야 합니다.
# 변수 정의는 루트 variables.tf (../../variables.tf)와 동일하게 유지하며,
# 환경별로 다른 기본값만 오버라이드합니다.
# ============================================================================

# 환경별 기본값 오버라이드 변수
variable "environment" {
  description = "환경 이름 (필수) - 예: dev, staging, prod, nw, devops"
  type        = string
  default     = "dev"  # Dev 환경 기본값
}

variable "project_name" {
  description = "프로젝트 이름 (필수)"
  type        = string
}

variable "purpose" {
  description = "용도/기능 (필수) - 예: main, dns, agent, cicd, search, nl2sql, chatbot, front, backend"
  type        = string
}

variable "asset_management" {
  description = "자산관리 (선택) - 예: resolver, pe, gitlab, runner, agw, cae, vm, aca"
  type        = string
  default     = null
}

variable "sequence_number" {
  description = "순번 (선택) - 예: 001, 002"
  type        = string
  default     = "001"
}

variable "resource_group_name" {
  description = "Resource Group 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "Virtual Network 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "container_app_environment_name" {
  description = "Container App Environment 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "koreacentral"
}

variable "subscription_id" {
  description = "Azure Subscription ID (선택, 지정하지 않으면 기본 subscription 사용)"
  type        = string
  default     = null
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
  # 주의: Dev 환경에서는 terraform.tfvars에서 필수로 제공해야 함
  # 기본값: ["10.0.0.0/16"] (terraform.tfvars.example 참조)
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Subnet configurations. Key is used as asset_management for naming convention. If name is not provided, it will be auto-generated using naming convention."
  type = map(object({
    name                        = optional(string) # 지정하지 않으면 네이밍 규칙 자동 적용
    address_prefixes            = list(string)
    network_security_group_id   = optional(string)
    route_table_id              = optional(string)
    service_endpoints           = optional(list(string))
    service_endpoint_policy_ids = optional(list(string))
    private_endpoint_network_policies_enabled = optional(bool) # Private Endpoint용 네트워크 정책 활성화 여부 (agw 제외 기본값: false)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
}

variable "container_apps_subnet_id" {
  description = "Subnet key for Container Apps"
  type        = string
  default     = null
}

variable "container_apps" {
  description = "Container App configurations. If name is not provided, it will be auto-generated using naming convention."
  type = map(object({
    name          = optional(string) # 명명규칙이 적용되면 자동 생성됨
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

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics Workspace ID"
  type        = string
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  type        = string
  default     = null
}

variable "log_analytics_workspace_suffix" {
  description = "Log Analytics Workspace suffix"
  type        = string
  default     = "laws"
}

variable "log_analytics_workspace_sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Log Analytics retention days"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "application_gateway_enabled" {
  description = "Whether to create Application Gateway"
  type        = bool
  default     = false
}

variable "application_gateway_name" {
  description = "Application Gateway 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
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
    auto_connect_container_apps   = optional(bool, true) # Container Apps FQDN 자동 연결 여부
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
      priority                    = optional(number) # 1-20000 사이의 값
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

# Container Registry 변수
variable "container_registry_enabled" {
  description = "Whether to create Container Registry"
  type        = bool
  default     = false
}

variable "container_registry_name" {
  description = "Container Registry 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "container_registry_config" {
  description = "Container Registry 설정"
  type = object({
    sku                           = optional(string, "Basic")
    admin_enabled                 = optional(bool, false)
    public_network_access_enabled = optional(bool, null)
    georeplications = optional(list(object({
      location                  = string
      regional_endpoint_enabled = optional(bool, true)
      zone_redundancy_enabled   = optional(bool, false)
      tags                      = optional(map(string), {})
    })), null)
    network_rule_set = optional(object({
      default_action = string
      ip_rules = optional(list(object({
        action   = string
        ip_range = string
      })), [])
      virtual_networks = optional(list(object({
        action    = string
        subnet_id = string
      })), [])
    }), null)
    retention_policy = optional(object({
      days    = number
      enabled = optional(bool, true)
    }), null)
    trust_policy = optional(object({
      enabled = bool
    }), null)
    encryption = optional(object({
      enabled            = bool
      key_vault_key_id   = optional(string)
      identity_client_id = optional(string)
    }), null)
    identity_type = optional(string, "SystemAssigned")
    identity_ids  = optional(list(string), [])
  })
  default = null
}

# Key Vault 변수
variable "key_vault_enabled" {
  description = "Whether to create Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_name" {
  description = "Key Vault 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "key_vault_config" {
  description = "Key Vault 설정"
  type = object({
    tenant_id                       = optional(string)
    sku_name                        = optional(string, "standard")
    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    rbac_authorization_enabled      = optional(bool, true)
    public_network_access_enabled   = optional(bool, null)
    purge_protection_enabled        = optional(bool, false)
    soft_delete_retention_days      = optional(number, 90)
    network_acls = optional(object({
      default_action             = string
      bypass                     = optional(string, "AzureServices")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), null)
    contacts = optional(list(object({
      email = string
      name  = optional(string)
      phone = optional(string)
    })), null)
    access_policies = optional(map(object({
      object_id               = string
      key_permissions         = optional(list(string), [])
      secret_permissions      = optional(list(string), [])
      certificate_permissions = optional(list(string), [])
      storage_permissions     = optional(list(string), [])
    })), {})
  })
  default = null
}

# Cosmos DB 변수
variable "cdb_enabled" {
  description = "Whether to create Cosmos DB"
  type        = bool
  default     = false
}

variable "cdb_name" {
  description = "Cosmos DB 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "cdb_config" {
  description = "Cosmos DB 설정"
  type = object({
    offer_type              = optional(string, null)
    kind                    = optional(string, null)
    consistency_level       = optional(string, null)
    max_interval_in_seconds = optional(number, 5)
    max_staleness_prefix    = optional(number, 100)
    capabilities            = optional(list(string), null)
    geo_locations = list(object({
      location          = string
      failover_priority = number
      zone_redundant    = optional(bool, false)
    }))
    backup = optional(object({
      type                = string
      interval_in_minutes = optional(number)
      retention_in_hours  = optional(number)
      storage_redundancy  = optional(string)
    }), null)
    cors_rule = optional(object({
      allowed_origins    = list(string)
      allowed_methods    = optional(list(string), [])
      allowed_headers    = optional(list(string), [])
      exposed_headers    = optional(list(string), [])
      max_age_in_seconds = optional(number)
    }), null)
    is_virtual_network_filter_enabled = optional(bool, false)
    virtual_network_rules = optional(list(object({
      id                                   = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
    ip_range_filter                    = optional(string, null)
    public_network_access_enabled      = optional(bool, null)
    enable_automatic_failover          = optional(bool, false)
    enable_multiple_write_locations    = optional(bool, false)
    access_key_metadata_writes_enabled = optional(bool, true)
    local_authentication_disabled      = optional(bool, false)
    identity_type                      = optional(string, null)
    identity_ids                       = optional(list(string), [])
    databases = optional(map(object({
      name       = string
      throughput = optional(number)
      autoscale_settings = optional(object({
        max_throughput = number
      }))
      tags = optional(map(string), {})
    })), {})
    containers = optional(map(object({
      name               = string
      database_name      = string
      partition_key_path = string
      throughput         = optional(number)
      autoscale_settings = optional(object({
        max_throughput = number
      }))
      indexing_policy = optional(object({
        indexing_mode  = optional(string)
        included_paths = optional(list(string), [])
        excluded_paths = optional(list(string), [])
      }))
      unique_keys = optional(list(object({
        paths = list(string)
      })), [])
      tags = optional(map(string), {})
    })), {})
  })
  default = null
}

# PostgreSQL 변수
variable "postgresql_enabled" {
  description = "Whether to create PostgreSQL"
  type        = bool
  default     = false
}

variable "postgresql_name" {
  description = "PostgreSQL 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "postgresql_config" {
  description = "PostgreSQL 설정"
  type = object({
    server_version                = optional(string, null)
    administrator_login           = string
    administrator_password        = string
    sku_name                      = optional(string, null)
    storage_mb                    = optional(number, null)
    backup_retention_days         = optional(number, null)
    geo_redundant_backup_enabled  = optional(bool, false)
    public_network_access_enabled = optional(bool, null)
    maintenance_window = optional(object({
      day_of_week  = number
      start_hour   = number
      start_minute = optional(number, 0)
    }), null)
    high_availability = optional(object({
      mode                      = string
      standby_availability_zone = optional(string)
    }), null)
    identity_type = optional(string, null)
    identity_ids  = optional(list(string), [])
    firewall_rules = optional(map(object({
      name             = string
      start_ip_address = string
      end_ip_address   = string
    })), {})
    databases = optional(map(object({
      name      = string
      charset   = optional(string)
      collation = optional(string)
      tags      = optional(map(string), {})
    })), {})
    default_charset       = optional(string, null)
    default_collation     = optional(string, null)
    server_configurations = optional(map(string), {})
  })
  default = null
}

# AI Foundry 변수
variable "foundry_enabled" {
  description = "Whether to create AI Foundry resources"
  type        = bool
  default     = false
}

variable "foundry_name" {
  description = "AI Foundry 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "foundry_config" {
  description = "AI Foundry 설정"
  type = object({
    storage_account_id                            = optional(string, null)
    storage_account_name                          = optional(string, null)
    storage_account_tier                          = optional(string, null)
    storage_account_replication_type              = optional(string, null)
    storage_account_public_network_access_enabled = optional(bool, null)
    storage_account_name_suffix                   = optional(string, null)
    public_network_access_enabled                 = optional(bool, null)
    identity_type                                 = optional(string, null)
    identity_ids                                  = optional(list(string), [])
    create_project                                = optional(bool, false)
    project_name                                  = optional(string, null)
    project_identity_type                         = optional(string, null)
    project_identity_ids                          = optional(list(string), [])
    deployments = optional(map(object({
      name                   = string
      model_name             = string
      model_format           = optional(string)
      model_version          = optional(string)
      rai_policy_name        = optional(string)
      version_upgrade_option = optional(string)
      scale = object({
        name     = optional(string)
        type     = optional(string)
        capacity = optional(number)
        family   = optional(string)
        size     = optional(string)
        tier     = optional(string)
      })
    })), {})
    project_deployments = optional(map(object({
      name                   = string
      model_name             = string
      model_format           = optional(string)
      model_version          = optional(string)
      rai_policy_name        = optional(string)
      version_upgrade_option = optional(string)
      scale = object({
        name     = optional(string)
        type     = optional(string)
        capacity = optional(number)
        family   = optional(string)
        size     = optional(string)
        tier     = optional(string)
      })
    })), {})
    cognitive_account_sku_name     = optional(string, null)
    cognitive_account_kind         = optional(string, null)
    cognitive_account_name_suffix  = optional(string, null)
    default_model_format           = optional(string, null)
    default_version_upgrade_option = optional(string, null)
    default_deployment_sku_type    = optional(string, null)
  })
  default = null
}

# OpenAI 변수
variable "openai_enabled" {
  description = "Whether to create OpenAI"
  type        = bool
  default     = false
}

variable "openai_name" {
  description = "OpenAI 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "openai_config" {
  description = "OpenAI 설정"
  type = object({
    sku_name                      = optional(string, null)
    kind                          = optional(string, null)
    public_network_access_enabled = optional(bool, null)
    identity_type                 = optional(string, null)
    identity_ids                  = optional(list(string), [])
    deployments = optional(map(object({
      name                   = string
      model_name             = string
      model_format           = optional(string)
      model_version          = optional(string)
      rai_policy_name        = optional(string)
      version_upgrade_option = optional(string)
      scale = object({
        type     = optional(string)
        capacity = optional(number)
        family   = optional(string)
        size     = optional(string)
        tier     = optional(string)
      })
    })), {})
    default_model_format           = optional(string, null)
    default_version_upgrade_option = optional(string, null)
    default_deployment_sku_type    = optional(string, null)
  })
  default = null
}

# Private Endpoints 변수
variable "private_endpoints_enabled" {
  description = "Whether to create Private Endpoints for PaaS services"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet key name for Private Endpoints (defaults to 'pe' if not specified)"
  type        = string
  default     = null
}

variable "private_dns_zones_config" {
  description = "Custom Private DNS Zone configurations (optional, defaults to standard Azure Private Link zones)"
  type = map(object({
    name                 = string
    virtual_network_ids  = optional(list(string), [])
    registration_enabled = optional(bool, false)
  }))
  default = null
}

variable "private_endpoints_config" {
  description = "Custom Private Endpoint configurations (optional, auto-generated if not provided)"
  type = map(object({
    name                            = optional(string)
    subnet_id                       = optional(string)
    private_connection_resource_id  = optional(string)
    subresource_names               = optional(list(string))
    private_dns_zone_key            = optional(string)
    private_service_connection_name = optional(string)
    is_manual_connection            = optional(bool, false)
    request_message                 = optional(string)
  }))
  default = null
}

variable "virtual_machines" {
  description = "Map of Virtual Machine configurations"
  type = map(object({
    name                          = string
    size                          = string
    subnet_id                     = string                    # Subnet key name (e.g., "vm")
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
  default = null
}

# ============================================================================
# 참고사항
# ============================================================================
# 이 파일의 변수 정의는 루트 variables.tf (../../variables.tf)와 동일하게 유지됩니다.
# 환경별로 다른 기본값만 오버라이드하며, 실제 값은 terraform.tfvars에서 관리합니다.
# 
# 변수 정의 변경 시:
# 1. 루트 variables.tf (../../variables.tf)를 먼저 수정
# 2. 이 파일도 동일하게 반영 (타입, 설명 등)
# 3. 환경별 기본값만 필요시 오버라이드
# ============================================================================
