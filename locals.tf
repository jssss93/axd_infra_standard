#===============================================================================
# Azure 리소스 기본값 정의
#===============================================================================
#
# 명명규칙은 modules/naming 모듈에서 관리됩니다.
# 자세한 내용은 modules/naming/main.tf를 참조하세요.
#
#===============================================================================

locals {
  #-----------------------------------------------------------------------------
  # 태그 설정
  #-----------------------------------------------------------------------------

  # 공통 태그 정의
  # 주의: timestamp()를 사용하면 매번 태그가 변경되어 리소스가 재생성될 수 있습니다.
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


  #-----------------------------------------------------------------------------
  # 서비스 기본값 정의
  #-----------------------------------------------------------------------------

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

  #-----------------------------------------------------------------------------
  # 보안 기본값
  #-----------------------------------------------------------------------------

  security_defaults = merge({
    public_network_access_enabled = false
    local_authentication_disabled = false # 기본적으로는 false (점진적 전환)
  }, var.security_defaults != null ? var.security_defaults : {})

  #-----------------------------------------------------------------------------
  # Private DNS Zone 기본값
  #-----------------------------------------------------------------------------

  default_private_dns_zones = {
    keyvault = {
      name                 = "privatelink.vaultcore.azure.net"
      virtual_network_ids  = []
      registration_enabled = false
    }
    cosmos = {
      name                 = "privatelink.documents.azure.com"
      virtual_network_ids  = []
      registration_enabled = false
    }
    postgres = {
      name                 = "privatelink.postgres.database.azure.com"
      virtual_network_ids  = []
      registration_enabled = false
    }
    acr = {
      name                 = "privatelink.azurecr.io"
      virtual_network_ids  = []
      registration_enabled = false
    }
  }

  #-----------------------------------------------------------------------------
  # Private Endpoint 서비스별 설정
  #-----------------------------------------------------------------------------

  private_endpoint_service_config = {
    keyvault = {
      subresource_names    = ["vault"]
      private_dns_zone_key = "keyvault"
    }
    cosmos = {
      subresource_names    = ["Sql"]
      private_dns_zone_key = "cosmos"
    }
    postgres = {
      subresource_names    = ["postgresqlServer"]
      private_dns_zone_key = "postgres"
    }
    acr = {
      subresource_names    = ["registry"]
      private_dns_zone_key = "acr"
    }
  }
}
