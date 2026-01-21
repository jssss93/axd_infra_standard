#===============================================================================
# Azure Infrastructure - Root Module
#===============================================================================
#
# 모듈 구조 및 의존성:
# ─────────────────────────────────────────────────────────────────────────────
#
#   ┌─────────┐
#   │   rg    │  (1) Resource Group - 기본 인프라
#   └────┬────┘
#        │
#   ┌────▼────┐
#   │networking│ (2) VNet, Subnet, AppGW, Private Endpoints
#   └────┬────┘
#        │
#   ┌────▼────┐
#   │  data   │  (3) Key Vault, ACR, Cosmos DB, PostgreSQL
#   └────┬────┘
#        │
#   ┌────▼────┐
#   │services │  (4) AI Foundry, OpenAI
#   └────┬────┘
#        │
#   ┌────▼────┐
#   │afterjob │  (5) Key Vault Secrets (모든 서비스 생성 후 실행)
#   └────┬────┘
#        │
#   ┌────▼────┐
#   │ compute │  (6) Container Apps, Virtual Machines
#   └─────────┘
#
# 사용 방법:
#   terraform init
#   terraform plan -var-file="terraform.tfvars"
#   terraform apply -var-file="terraform.tfvars"
#
#===============================================================================

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

#-------------------------------------------------------------------------------
# Naming Module - 리소스 명명규칙 처리
#-------------------------------------------------------------------------------
module "naming" {
  source = "./modules/naming"

  project_name     = var.project_name
  environment      = var.environment
  purpose          = var.purpose
  asset_management = var.asset_management
  sequence_number  = var.sequence_number

  custom_names = {
    resource_group            = var.resource_group_name
    vnet                      = var.vnet_name
    key_vault                 = var.key_vault_name
    container_registry        = var.container_registry_name
    cosmos_db                 = var.cdb_name
    postgresql                = var.postgresql_name
    application_gateway       = var.application_gateway_name
    container_app_environment = var.container_app_environment_name
    foundry                   = var.foundry_name
    openai                    = var.openai_name
    log_analytics_workspace   = var.log_analytics_workspace_name
    storage_account           = var.foundry_config != null ? try(var.foundry_config.storage_account_name, null) : null
    public_ip_agw             = var.application_gateway_config != null ? try(var.application_gateway_config.public_ip_name, null) : null
  }
}

# Resource Group Module
module "rg" {
  source = "./modules/foundation/rg"

  name     = module.naming.resource_group
  location = var.location
  tags     = local.merged_tags
}

# Networking Module (VNet, Subnets, Application Gateway, Private Endpoints)
module "networking" {
  source = "./modules/networking"

  resource_group_name = module.rg.name
  location            = module.rg.location
  vnet_name           = module.naming.vnet
  vnet_address_space  = var.vnet_address_space
  dns_servers         = var.dns_servers
  subnets = module.naming.enabled ? {
    for k, v in var.subnets : k => merge(v, {
      name = try(v.name, null) != null ? v.name : "${module.naming.subnet_name.prefix}-${k}-${module.naming.subnet_name.suffix}"
    })
  } : var.subnets
  application_gateway_enabled   = var.application_gateway_enabled
  application_gateway_name      = module.naming.application_gateway
  application_gateway_subnet_id = var.application_gateway_subnet_id
  # Application Gateway Config에서 public_ip_name이 없으면 naming 모듈 사용
  application_gateway_config = var.application_gateway_config != null ? merge(var.application_gateway_config, {
    public_ip_name = try(var.application_gateway_config.public_ip_name, null) != null ? var.application_gateway_config.public_ip_name : module.naming.public_ip_agw
  }) : null
  container_app_fqdns           = module.compute.container_app_fqdns
  private_endpoints_enabled = var.private_endpoints_enabled
  # Private DNS Zones: 변수가 제공되면 사용, 없으면 기본값 사용
  private_dns_zones = var.private_endpoints_enabled ? (
    var.private_dns_zones_config != null ? var.private_dns_zones_config : local.default_private_dns_zones
  ) : {}
  # Private Endpoints: 변수가 제공되면 사용, 없으면 기본값 생성 (null 값 필터링)
  private_endpoints = var.private_endpoints_config != null ? var.private_endpoints_config : (
    var.private_endpoints_enabled ? {
      for k, v in {
        keyvault = var.key_vault_enabled && var.key_vault_config != null ? {
          name                            = "${module.naming.key_vault}-pe"
          subnet_id                       = var.private_endpoint_subnet_id != null ? module.networking.subnet_ids[var.private_endpoint_subnet_id] : module.networking.subnet_ids["pe"]
          private_connection_resource_id  = module.data.key_vault_id
          subresource_names               = local.private_endpoint_service_config.keyvault.subresource_names
          private_dns_zone_key            = local.private_endpoint_service_config.keyvault.private_dns_zone_key
          is_manual_connection            = false
          private_service_connection_name = null
          request_message                 = null
        } : null
        cosmos = var.cdb_enabled && var.cdb_config != null ? {
          name                            = "${module.naming.cosmos_db}-pe"
          subnet_id                       = var.private_endpoint_subnet_id != null ? module.networking.subnet_ids[var.private_endpoint_subnet_id] : module.networking.subnet_ids["pe"]
          private_connection_resource_id  = module.data.cdb_id
          subresource_names               = local.private_endpoint_service_config.cosmos.subresource_names
          private_dns_zone_key            = local.private_endpoint_service_config.cosmos.private_dns_zone_key
          is_manual_connection            = false
          private_service_connection_name = null
          request_message                 = null
        } : null
        postgres = var.postgresql_enabled && var.postgresql_config != null ? {
          name                            = "${module.naming.postgresql}-pe"
          subnet_id                       = var.private_endpoint_subnet_id != null ? module.networking.subnet_ids[var.private_endpoint_subnet_id] : module.networking.subnet_ids["pe"]
          private_connection_resource_id  = module.data.postgresql_id
          subresource_names               = local.private_endpoint_service_config.postgres.subresource_names
          private_dns_zone_key            = local.private_endpoint_service_config.postgres.private_dns_zone_key
          is_manual_connection            = false
          private_service_connection_name = null
          request_message                 = null
        } : null
        acr = var.container_registry_enabled && var.container_registry_config != null ? {
          name                            = "${module.naming.container_registry}-pe"
          subnet_id                       = var.private_endpoint_subnet_id != null ? module.networking.subnet_ids[var.private_endpoint_subnet_id] : module.networking.subnet_ids["pe"]
          private_connection_resource_id  = module.data.container_registry_id
          subresource_names               = local.private_endpoint_service_config.acr.subresource_names
          private_dns_zone_key            = local.private_endpoint_service_config.acr.private_dns_zone_key
          is_manual_connection            = false
          private_service_connection_name = null
          request_message                 = null
        } : null
      } : k => v if v != null
    } : {}
  )

  tags = local.merged_tags
}

# Data Module (Key Vault, Container Registry, Cosmos DB, PostgreSQL)
module "data" {
  source = "./modules/data"

  resource_group_name        = module.rg.name
  location                   = module.rg.location
  key_vault_enabled          = var.key_vault_enabled
  key_vault_name             = module.naming.key_vault
  key_vault_config           = var.key_vault_config
  container_registry_enabled = var.container_registry_enabled
  container_registry_name    = module.naming.container_registry
  container_registry_config  = var.container_registry_config
  cdb_enabled          = var.cdb_enabled
  cdb_name             = module.naming.cosmos_db
  cdb_config           = var.cdb_config
  postgresql_enabled         = var.postgresql_enabled
  postgresql_name            = module.naming.postgresql
  postgresql_config          = var.postgresql_config

  tags = local.merged_tags
}

# Key Vault ID for other modules
locals {
  key_vault_id = module.data.key_vault_id
}

# Services Module (AI Foundry, OpenAI)
module "services" {
  source = "./modules/services"

  resource_group_name = module.rg.name
  location            = module.rg.location
  key_vault_id        = local.key_vault_id
  foundry_enabled     = var.foundry_enabled
  foundry_name        = module.naming.foundry
  # Foundry Config에서 storage_account_name 처리
  # storage_account_id가 있으면 기존 리소스 사용
  # storage_account_name이 명시적으로 설정되어 있으면 사용
  # 둘 다 없으면 null로 두어 foundry 모듈에서 자동 생성 (foundry name 기반으로 생성되므로 naming과 호환됨)
  foundry_config = var.foundry_config != null ? merge(var.foundry_config, {
    # storage_account_name은 foundry 모듈의 기본 로직 사용 (foundry name 기반으로 생성)
    # 명시적으로 설정된 경우만 사용
  }) : null
  openai_enabled = var.openai_enabled
  openai_name    = module.naming.openai
  openai_config  = var.openai_config

  tags = local.merged_tags

  depends_on = [module.data]
}

# Afterjob Module - Key Vault Secrets (executed last, after all services are created)
# This module creates all Key Vault secrets after all services are created
module "afterjob" {
  source = "./modules/data/afterjob"

  key_vault_id      = local.key_vault_id
  key_vault_enabled = var.key_vault_enabled
  create_secrets    = false # Temporarily disabled due to Key Vault private endpoint access restrictions

  # ACR secrets (from data module)
  container_registry_enabled = var.container_registry_enabled
  acr_login_server           = module.data.container_registry_login_server
  acr_admin_username         = module.data.container_registry_admin_username
  acr_admin_password         = module.data.container_registry_admin_password

  # Cosmos DB secrets (from data module)
  cdb_enabled      = var.cdb_enabled
  cdb_endpoint      = module.data.cdb_endpoint
  cdb_primary_key   = module.data.cdb_primary_key
  cdb_secondary_key = module.data.cdb_secondary_key

  # PostgreSQL secrets (from data module and variables)
  postgresql_enabled     = var.postgresql_enabled
  postgresql_password    = var.postgresql_enabled && var.postgresql_config != null ? var.postgresql_config.administrator_password : null
  postgresql_fqdn        = module.data.postgresql_fqdn
  postgresql_admin_login = var.postgresql_enabled && var.postgresql_config != null ? var.postgresql_config.administrator_login : null

  # Foundry secrets (from services module)
  foundry_enabled  = var.foundry_enabled
  foundry_endpoint = module.services.foundry_endpoint

  # OpenAI secrets (from services module)
  openai_enabled       = var.openai_enabled
  openai_endpoint      = module.services.openai_endpoint
  openai_primary_key   = module.services.openai_primary_access_key
  openai_secondary_key = module.services.openai_secondary_access_key

  tags = local.merged_tags

  depends_on = [
    module.data,
    module.services
  ]
}

# Key Vault Secret IDs (from afterjob module)
locals {
  key_vault_secret_ids = module.afterjob.key_vault_secret_ids
}

# Compute Module (Container Apps + Virtual Machines)
module "compute" {
  source = "./modules/compute"

  resource_group_name            = module.rg.name
  location                       = module.rg.location
  container_app_environment_name = module.naming.container_app_environment
  infrastructure_subnet_id       = var.container_apps_subnet_id != null ? module.networking.subnet_ids[var.container_apps_subnet_id] : null
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_workspace_name   = var.log_analytics_workspace_name != null ? var.log_analytics_workspace_name : module.naming.log_analytics_workspace
  log_analytics_workspace_suffix = var.log_analytics_workspace_suffix
  log_analytics_workspace_sku    = var.log_analytics_workspace_sku
  log_analytics_retention_days   = var.log_analytics_retention_days
  # Container Apps 이름 처리 (naming 모듈 활용)
  container_apps = module.naming.enabled ? {
    for k, v in var.container_apps : k => merge(v, {
      name = try(v.name, null) != null && try(v.name, "") != "" ? v.name : (
        module.naming.container_app.prefix != "" ?
        "${module.naming.container_app.prefix}-${k}${module.naming.container_app.sequence_number != null && module.naming.container_app.sequence_number != "" ? "-${module.naming.container_app.sequence_number}" : ""}" :
        k
      )
    })
    } : {
    for k, v in var.container_apps : k => merge(v, {
      name = try(v.name, null) != null && try(v.name, "") != "" ? v.name : k
    })
  }
  virtual_machines = var.virtual_machines != null ? {
    for k, v in var.virtual_machines : k => merge(v, {
      subnet_id = module.networking.subnet_ids[v.subnet_id]
    })
  } : {}

  # Key Vault integration
  key_vault_id      = local.key_vault_id
  key_vault_secrets = local.key_vault_secret_ids

  tags = local.merged_tags

  depends_on = [module.data]
}
