locals {
  # Secret 이름 기본값 정의
  secret_names = merge({
    acr_login_server       = "acr-login-server"
    acr_admin_username     = "acr-admin-username"
    acr_admin_password     = "acr-admin-password"
    cosmosdb_endpoint      = "cosmosdb-endpoint"
    cosmosdb_primary_key   = "cosmosdb-primary-key"
    cosmosdb_secondary_key = "cosmosdb-secondary-key"
    postgresql_password    = "postgresql-password"
    postgresql_fqdn        = "postgresql-fqdn"
    postgresql_admin_login = "postgresql-admin-login"
    foundry_endpoint       = "foundry-endpoint"
    openai_endpoint        = "openai-endpoint"
    openai_primary_key     = "openai-primary-key"
    openai_secondary_key   = "openai-secondary-key"
  }, var.secret_names != null ? var.secret_names : {})

  # Secret content type 기본값
  secret_content_type = var.secret_content_type != null ? var.secret_content_type : "text/plain"
}
