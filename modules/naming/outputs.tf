#===============================================================================
# Naming Module - Outputs
#===============================================================================

output "enabled" {
  description = "명명규칙 활성화 여부"
  value       = local.enabled
}

output "prefix" {
  description = "기본 프리픽스 ({project}-{environment}-{purpose})"
  value       = local.prefix
}

output "prefix_alphanum" {
  description = "영숫자만 포함된 프리픽스 (ACR, Storage Account용)"
  value       = local.prefix_alphanum
}

#-------------------------------------------------------------------------------
# 개별 리소스 이름 (커스텀 이름 우선)
#-------------------------------------------------------------------------------

output "resource_group" {
  description = "Resource Group 이름"
  value       = coalesce(var.custom_names.resource_group, try(local.generated_names.resource_group, null))
}

output "vnet" {
  description = "Virtual Network 이름"
  value       = coalesce(var.custom_names.vnet, try(local.generated_names.vnet, null))
}

output "application_gateway" {
  description = "Application Gateway 이름"
  value       = coalesce(var.custom_names.application_gateway, try(local.generated_names.application_gateway, null))
}

output "container_app_environment" {
  description = "Container App Environment 이름"
  value       = coalesce(var.custom_names.container_app_environment, try(local.generated_names.container_app_environment, null))
}

output "key_vault" {
  description = "Key Vault 이름 (최대 24자)"
  value       = coalesce(var.custom_names.key_vault, try(local.generated_names.key_vault, null))
}

output "container_registry" {
  description = "Container Registry 이름 (영숫자만)"
  value       = coalesce(var.custom_names.container_registry, try(local.generated_names.container_registry, null))
}

output "cosmos_db" {
  description = "Cosmos DB 이름"
  value       = coalesce(var.custom_names.cosmos_db, try(local.generated_names.cosmos_db, null))
}

output "postgresql" {
  description = "PostgreSQL 이름"
  value       = coalesce(var.custom_names.postgresql, try(local.generated_names.postgresql, null))
}

output "foundry" {
  description = "AI Foundry 이름"
  value       = coalesce(var.custom_names.foundry, try(local.generated_names.foundry, null))
}

output "openai" {
  description = "OpenAI 이름"
  value       = coalesce(var.custom_names.openai, try(local.generated_names.openai, null))
}

output "log_analytics_workspace" {
  description = "Log Analytics Workspace 이름"
  value       = coalesce(var.custom_names.log_analytics_workspace, try(local.generated_names.log_analytics_workspace, null))
}

output "storage_account" {
  description = "Storage Account 이름 (영숫자만, 최대 24자)"
  value       = coalesce(var.custom_names.storage_account, try(local.generated_names.storage_account, null))
}

output "public_ip_agw" {
  description = "Application Gateway용 Public IP 이름"
  value       = coalesce(var.custom_names.public_ip_agw, try(local.generated_names.public_ip_agw, null))
}

#-------------------------------------------------------------------------------
# 동적 이름 생성용
#-------------------------------------------------------------------------------

output "subnet_suffix" {
  description = "Subnet 접미사"
  value       = local.subnet_suffix
}

output "container_app_prefix" {
  description = "Container App 이름 프리픽스"
  value       = local.container_app_prefix
}

#-------------------------------------------------------------------------------
# 전체 이름 맵 (한 번에 참조용)
#-------------------------------------------------------------------------------

output "names" {
  description = "모든 리소스 이름을 포함하는 맵"
  value = local.enabled ? {
    resource_group            = coalesce(var.custom_names.resource_group, local.generated_names.resource_group)
    vnet                      = coalesce(var.custom_names.vnet, local.generated_names.vnet)
    application_gateway       = coalesce(var.custom_names.application_gateway, local.generated_names.application_gateway)
    container_app_environment = coalesce(var.custom_names.container_app_environment, local.generated_names.container_app_environment)
    key_vault                 = coalesce(var.custom_names.key_vault, local.generated_names.key_vault)
    container_registry        = coalesce(var.custom_names.container_registry, local.generated_names.container_registry)
    cosmos_db                 = coalesce(var.custom_names.cosmos_db, local.generated_names.cosmos_db)
    postgresql                = coalesce(var.custom_names.postgresql, local.generated_names.postgresql)
    foundry                   = coalesce(var.custom_names.foundry, local.generated_names.foundry)
    openai                    = coalesce(var.custom_names.openai, local.generated_names.openai)
    log_analytics_workspace   = coalesce(var.custom_names.log_analytics_workspace, local.generated_names.log_analytics_workspace)
    storage_account           = coalesce(var.custom_names.storage_account, local.generated_names.storage_account)
    public_ip_agw             = coalesce(var.custom_names.public_ip_agw, local.generated_names.public_ip_agw)
  } : {}
}

#-------------------------------------------------------------------------------
# Subnet 이름 생성 함수
#-------------------------------------------------------------------------------

output "subnet_name" {
  description = "Subnet 이름 생성 정보"
  value = {
    prefix = local.prefix
    suffix = local.subnet_suffix
    # 사용법: "${module.naming.subnet_name.prefix}-{key}-${module.naming.subnet_name.suffix}"
  }
}

#-------------------------------------------------------------------------------
# Container App 이름 생성 함수
#-------------------------------------------------------------------------------

output "container_app" {
  description = "Container App 이름 생성 정보"
  value = {
    enabled         = local.enabled
    prefix          = local.container_app_prefix
    sequence_number = var.sequence_number
    # 사용법: "${module.naming.container_app.prefix}-{app_name}[-${module.naming.container_app.sequence_number}]"
  }
}

#-------------------------------------------------------------------------------
# Public IP 이름 생성 함수 (VM용)
#-------------------------------------------------------------------------------

output "public_ip_vm" {
  description = "VM용 Public IP 이름 생성 정보"
  value = {
    prefix = local.public_ip_vm_prefix
    # 사용법: "${module.naming.public_ip_vm.prefix}-{vm_name}-pip"
  }
}

#-------------------------------------------------------------------------------
# Virtual Machine 이름 생성 함수
#-------------------------------------------------------------------------------

output "virtual_machine" {
  description = "Virtual Machine 이름 생성 정보"
  value = {
    prefix = local.virtual_machine_prefix
    # 사용법: "${module.naming.virtual_machine.prefix}-{vm_name}"
  }
}

#-------------------------------------------------------------------------------
# Private Endpoint 이름 생성 함수
#-------------------------------------------------------------------------------

output "private_endpoint" {
  description = "Private Endpoint 이름 생성 정보"
  value = {
    suffix = "pe"
    # 사용법: "{resource_name}-${module.naming.private_endpoint.suffix}"
  }
}
