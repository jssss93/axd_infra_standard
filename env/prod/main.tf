terraform {
  backend "azurerm" {
    # Backend 설정은 terraform init 시 -backend-config로 전달하거나
    # backend.tfvars 파일로 관리하는 것을 권장합니다
  }
}

module "infrastructure" {
  source = "../../"

  # Azure Subscription
  subscription_id = var.subscription_id

  # 네이밍 규칙 변수 (자동 네이밍 활성화)
  project_name     = var.project_name
  environment      = var.environment
  purpose          = var.purpose
  asset_management = var.asset_management
  sequence_number  = var.sequence_number

  # Resource Group (네이밍 규칙 적용 또는 직접 지정)
  resource_group_name = var.resource_group_name != null ? var.resource_group_name : null
  location            = var.location

  # Network (네이밍 규칙 적용 또는 직접 지정)
  vnet_name          = var.vnet_name != null ? var.vnet_name : null
  vnet_address_space = var.vnet_address_space
  dns_servers        = var.dns_servers
  subnets            = var.subnets

  # Container Apps (네이밍 규칙 적용 또는 직접 지정)
  container_app_environment_name = var.container_app_environment_name != null ? var.container_app_environment_name : null
  container_apps_subnet_id       = var.container_apps_subnet_id
  container_apps                 = var.container_apps

  # Log Analytics
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_workspace_name   = var.log_analytics_workspace_name
  log_analytics_workspace_suffix = var.log_analytics_workspace_suffix
  log_analytics_workspace_sku    = var.log_analytics_workspace_sku
  log_analytics_retention_days   = var.log_analytics_retention_days

  # Tags
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
    },
    var.common_tags
  )
  tags = var.tags
}
