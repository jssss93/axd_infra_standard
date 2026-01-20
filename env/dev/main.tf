terraform {
  # Backend 설정은 terraform init 시 -backend-config로 전달하거나
  # backend.tfvars 파일로 관리하는 것을 권장합니다
  # 임시로 local backend 사용 (실제 배포 시 azurerm backend 설정 필요)
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

  # Virtual Machines (선택)
  virtual_machines = var.virtual_machines

  # Application Gateway (선택)
  application_gateway_enabled   = var.application_gateway_enabled
  application_gateway_name      = var.application_gateway_name
  application_gateway_subnet_id = var.application_gateway_subnet_id
  application_gateway_config    = var.application_gateway_config

  # Log Analytics
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_workspace_name   = var.log_analytics_workspace_name
  log_analytics_workspace_suffix = var.log_analytics_workspace_suffix
  log_analytics_workspace_sku    = var.log_analytics_workspace_sku
  log_analytics_retention_days   = var.log_analytics_retention_days

  # Container Registry (선택)
  container_registry_enabled = var.container_registry_enabled
  container_registry_name    = var.container_registry_name
  container_registry_config  = var.container_registry_config

  # Key Vault (선택)
  key_vault_enabled = var.key_vault_enabled
  key_vault_name    = var.key_vault_name
  key_vault_config  = var.key_vault_config

  # Cosmos DB (선택)
  cosmos_db_enabled = var.cosmos_db_enabled
  cosmos_db_name    = var.cosmos_db_name
  cosmos_db_config  = var.cosmos_db_config

  # PostgreSQL (선택)
  postgresql_enabled = var.postgresql_enabled
  postgresql_name    = var.postgresql_name
  postgresql_config  = var.postgresql_config

  # AI Foundry (선택)
  foundry_enabled = var.foundry_enabled
  foundry_name    = var.foundry_name
  foundry_config  = var.foundry_config

  # OpenAI (선택)
  openai_enabled = var.openai_enabled
  openai_name    = var.openai_name
  openai_config  = var.openai_config

  # Private Endpoints (선택)
  private_endpoints_enabled  = var.private_endpoints_enabled
  private_endpoint_subnet_id = var.private_endpoint_subnet_id

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
