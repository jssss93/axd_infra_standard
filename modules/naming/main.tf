#===============================================================================
# Naming Module - Azure 리소스 명명규칙
#===============================================================================
#
# 명명규칙 형식: {project}-{environment}-{purpose}-{resource_type}[-{sequence}]
#
# Azure 리소스별 제약사항:
# - Container Registry: 영숫자만 허용, 최대 50자
# - Key Vault: 최대 24자
# - Storage Account: 소문자+숫자만, 최대 24자
# - 대부분의 리소스: 하이픈 허용, 최대 63자
#
#===============================================================================

locals {
  # 명명규칙 활성화 조건: 필수 변수가 모두 설정된 경우
  enabled = var.project_name != null && var.environment != null && var.purpose != null

  # 기본 프리픽스
  prefix = local.enabled ? "${var.project_name}-${var.environment}-${var.purpose}" : ""

  # 영숫자만 허용하는 프리픽스 (ACR, Storage Account용)
  prefix_alphanum = local.enabled ? lower(replace(local.prefix, "-", "")) : ""

  # 리소스별 명명규칙 정의
  generated_names = local.enabled ? {
    # Resource Group: {project}-{env}-{purpose}-rg
    resource_group = "${local.prefix}-rg"

    # Virtual Network: {project}-{env}-{purpose}-vnet
    vnet = "${local.prefix}-vnet"

    # Application Gateway: {project}-{env}-{purpose}-agw
    application_gateway = "${local.prefix}-agw"

    # Container App Environment: {project}-{env}-{purpose}-cae-{seq}
    container_app_environment = "${local.prefix}-cae-${var.sequence_number != null && var.sequence_number != "" ? var.sequence_number : "001"}"

    # Key Vault: {project}-{env}-{purpose}-kv (최대 24자)
    key_vault = substr("${local.prefix}-kv", 0, 24)

    # Container Registry: {project}{env}{purpose}acr (영숫자만)
    container_registry = substr("${local.prefix_alphanum}acr", 0, 50)

    # Cosmos DB: {project}-{env}-{purpose}-cdb
    cosmos_db = "${local.prefix}-cdb"

    # PostgreSQL: {project}-{env}-{purpose}-postgres
    postgresql = "${local.prefix}-postgres"

    # AI Foundry: {project}-{env}-{purpose}-foundry
    foundry = "${local.prefix}-foundry"

    # OpenAI: {project}-{env}-{purpose}-openai
    openai = "${local.prefix}-openai"

    # Log Analytics Workspace: {project}-{env}-{purpose}-laws
    log_analytics_workspace = "${local.prefix}-laws"

    # Storage Account: {project}{env}{purpose}sa (영숫자만, 최대 24자)
    storage_account = substr("${local.prefix_alphanum}sa", 0, 24)

    # Public IP (Application Gateway용): {project}-{env}-{purpose}-agw-pip
    public_ip_agw = "${local.prefix}-agw-pip"

    # Public IP (VM용): {project}-{env}-{purpose}-vm-{name}-pip
    # 동적 생성 함수로 처리

    # Virtual Machine: {project}-{env}-{purpose}-vm-{name}
    # 동적 생성 함수로 처리

    # Private Endpoint: {resource_name}-pe
    # 동적 생성 함수로 처리
  } : {}

  # Subnet 이름 생성 함수
  subnet_suffix = "sbn"

  # Container App 이름 생성용 정보
  container_app_prefix = local.enabled ? (
    var.asset_management != null && var.asset_management != ""
    ? "${local.prefix}-aca"
    : local.prefix
  ) : ""

  # Public IP 이름 생성 함수 (VM용)
  public_ip_vm_prefix = local.enabled ? "${local.prefix}-vm" : "vm"

  # Virtual Machine 이름 생성 함수
  virtual_machine_prefix = local.enabled ? "${local.prefix}-vm" : "vm"
}
