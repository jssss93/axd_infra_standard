locals {
  # 공통 태그 정의
  # 주의: timestamp()를 사용하면 매번 태그가 변경되어 리소스가 재생성될 수 있습니다.
  # CreatedDate는 리소스 생성 시점에만 설정되도록 하거나 제거하는 것을 권장합니다.
  common_tags = {
    ManagedBy   = "Terraform"
    # CreatedDate = formatdate("YYYY-MM-DD", timestamp())  # 주석 처리: 리소스 재생성 방지
    Owner       = "jongsu.choi@kt.com"
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
}
