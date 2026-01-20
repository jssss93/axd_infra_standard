locals {
  # 공통 태그 정의
  # 주의: timestamp()를 사용하면 매번 태그가 변경되어 리소스가 재생성될 수 있습니다.
  # CreatedDate는 리소스 생성 시점에만 설정되도록 하거나 제거하는 것을 권장합니다.
  common_tags = {
    ManagedBy = "Terraform"
    Owner     = "jongsu.choi@kt.com"
  }

  # 사용자 태그와 공통 태그 병합
  merged_tags = merge(
    local.common_tags,
    var.common_tags,
    var.tags
  )

  # 네이밍 규칙 함수
  # 형식: {프로젝트}-{환경}-{용도/기능}-{자산관리(선택)}-{리소스명}-{순번(선택)}
  # 네이밍 규칙 변수가 제공된 경우에만 자동 네이밍 적용
  use_naming_convention = var.project_name != null && var.environment != null && var.purpose != null

  naming = local.use_naming_convention ? {
    # Resource Group: {프로젝트}-{환경}-{용도/기능}-rg
    resource_group = "${var.project_name}-${var.environment}-${var.purpose}-rg"

    # Virtual Network: {프로젝트}-{환경}-{용도/기능}-vnet
    vnet = "${var.project_name}-${var.environment}-${var.purpose}-vnet"

    # Container Apps Environment: {프로젝트}-{환경}-{용도/기능}-cae-{순번}
    container_app_environment = var.sequence_number != null && var.sequence_number != "" ? "${var.project_name}-${var.environment}-${var.purpose}-cae-${var.sequence_number}" : "${var.project_name}-${var.environment}-${var.purpose}-cae-001"

    # Application Gateway: {프로젝트}-{환경}-{용도/기능}-agw
    application_gateway = "${var.project_name}-${var.environment}-${var.purpose}-agw"

    # Container Registry: {프로젝트}{환경}{용도/기능}acr (하이픈 제거, 영숫자만 허용)
    container_registry = "${replace("${var.project_name}${var.environment}${var.purpose}acr", "-", "")}"

    # Key Vault: {프로젝트}-{환경}-{용도/기능}-kv
    key_vault = "${var.project_name}-${var.environment}-${var.purpose}-kv"

    # Cosmos DB: {프로젝트}-{환경}-{용도/기능}-cosmos
    cosmos_db = "${var.project_name}-${var.environment}-${var.purpose}-cdb"

    # PostgreSQL: {프로젝트}-{환경}-{용도/기능}-postgres
    postgresql = "${var.project_name}-${var.environment}-${var.purpose}-postgres"

    # AI Foundry: {프로젝트}-{환경}-{용도/기능}-foundry
    foundry = "${var.project_name}-${var.environment}-${var.purpose}-foundry"

    # OpenAI: {프로젝트}-{환경}-{용도/기능}-openai
    openai = "${var.project_name}-${var.environment}-${var.purpose}-openai"
  } : {}

  # Container Apps 이름 생성 함수
  # 형식: {프로젝트}-{환경}-{용도/기능}-aca-{리소스명}-{순번(선택)}
  # 또는: {프로젝트}-{환경}-{용도/기능}-{리소스명}-{순번(선택)} (asset_management가 없는 경우)
  container_apps = local.use_naming_convention ? {
    for k, v in var.container_apps : k => merge(v, {
      name = lookup(v, "name", null) != null && lookup(v, "name", null) != "" ? (
        # 이미 명명규칙으로 시작하는 경우 그대로 사용, 아니면 사용자 지정 이름 사용
        startswith(v.name, "${var.project_name}-${var.environment}-${var.purpose}") ? v.name : v.name
        ) : (
        # name이 없으면 자동 생성
        var.asset_management != null && var.asset_management != "" ?
        "${var.project_name}-${var.environment}-${var.purpose}-aca-${k}${var.sequence_number != null && var.sequence_number != "" ? "-${var.sequence_number}" : ""}" :
        "${var.project_name}-${var.environment}-${var.purpose}-${k}${var.sequence_number != null && var.sequence_number != "" ? "-${var.sequence_number}" : ""}"
      )
    })
    } : {
    # 명명규칙이 적용되지 않는 경우, name이 없으면 키를 사용
    for k, v in var.container_apps : k => merge(v, {
      name = lookup(v, "name", null) != null && lookup(v, "name", null) != "" ? v.name : k
    })
  }

  # 공통 기본값 정의
  defaults = {
    # AI/Cognitive Services 기본값
    cognitive_account_kind = "OpenAI"
    cognitive_account_sku  = "S0"
    model_format           = "OpenAI"
    version_upgrade_option = "OnceNewDefaultVersionAvailable"
    deployment_sku_type    = "Standard"

    # Storage Account 기본값
    storage_account_tier             = "Standard"
    storage_account_replication_type = "LRS"

    # Identity 기본값
    identity_type = "SystemAssigned"

    # Container Apps 기본값
    container_app_revision_mode = "Single"
    container_app_min_replicas  = 0
    container_app_max_replicas  = 10
    container_app_cpu           = 0.25
    container_app_memory        = "0.5Gi"
    container_app_identity_type = "SystemAssigned"

    # Log Analytics 기본값
    log_analytics_workspace_suffix = "laws"
    log_analytics_workspace_sku    = "PerGB2018"

    # Cosmos DB 기본값
    cosmos_offer_type        = "Standard"
    cosmos_kind              = "GlobalDocumentDB"
    cosmos_consistency_level = "Session"
    cosmos_indexing_mode     = "consistent"

    # PostgreSQL 기본값
    postgresql_server_version        = "14"
    postgresql_sku_name              = "B_Standard_B1ms"
    postgresql_storage_mb            = 32768
    postgresql_backup_retention_days = 7
    postgresql_charset               = "UTF8"
    postgresql_collation             = "en_US.utf8"

    # 네이밍 접미사
    cognitive_account_name_suffix = "cog"
    storage_account_name_suffix   = "sa"

    # Key Vault Secret 기본값
    secret_content_type = "text/plain"
  }

  # 보안 기본값 (환경별로 오버라이드 가능)
  security_defaults = merge({
    public_network_access_enabled = false
    local_authentication_disabled = false # 기본적으로는 false (점진적 전환)
  }, var.security_defaults != null ? var.security_defaults : {})
}
