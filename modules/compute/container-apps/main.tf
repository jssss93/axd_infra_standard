# Log Analytics Workspace (Container Apps Environment에 필요)
resource "azurerm_log_analytics_workspace" "this" {
  count               = var.log_analytics_workspace_id == null ? 1 : 0
  name                = var.log_analytics_workspace_name != null ? var.log_analytics_workspace_name : "${var.container_app_environment_name}-${var.log_analytics_workspace_suffix != null ? var.log_analytics_workspace_suffix : "laws"}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku != null ? var.log_analytics_workspace_sku : "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = var.tags
}

# Container App Environment
resource "azurerm_container_app_environment" "this" {
  name                = var.container_app_environment_name
  location            = var.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_id = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : azurerm_log_analytics_workspace.this[0].id

  infrastructure_subnet_id = var.infrastructure_subnet_id

  tags = var.tags

  # infrastructure_resource_group_name은 읽기 전용 속성이므로 변경 무시
  # workload_profile은 Azure가 기본값(Consumption)으로 자동 설정하므로 변경 무시
  lifecycle {
    ignore_changes = [
      infrastructure_resource_group_name,
      workload_profile
    ]
  }
}

# Container Apps
resource "azurerm_container_app" "this" {
  for_each = var.container_apps

  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = try(each.value.revision_mode, var.default_revision_mode != null ? var.default_revision_mode : "Single")

  # System Assigned Identity - always enabled
  identity {
    type = var.container_app_identity_type != null ? var.container_app_identity_type : "SystemAssigned"
  }

  # Key Vault secrets reference - only include secrets used by this container app
  # Filter var.key_vault_secrets to only include secrets referenced in each.value.secrets
  dynamic "secret" {
    for_each = var.key_vault_id != null ? {
      for secret_name, secret_id in var.key_vault_secrets : secret_name => secret_id
      if secret_id != null && contains(toset([
        for s in try(each.value.secrets, []) : s.secret_name
      ]), secret_name)
    } : {}
    content {
      name                = secret.key
      key_vault_secret_id = secret.value
      identity            = var.container_app_identity_type == "UserAssigned" ? "user" : "system" # "system" for SystemAssigned, "user" for UserAssigned
    }
  }

  template {
    min_replicas = try(each.value.min_replicas, var.default_min_replicas != null ? var.default_min_replicas : 0)
    max_replicas = try(each.value.max_replicas, var.default_max_replicas != null ? var.default_max_replicas : 10)

    container {
      name   = try(each.value.container_name, null) != null ? each.value.container_name : each.key # Container 블록의 name은 키를 사용 (또는 명시적으로 지정)
      image  = each.value.image
      cpu    = try(each.value.cpu, var.default_cpu != null ? var.default_cpu : 0.25)
      memory = try(each.value.memory, var.default_memory != null ? var.default_memory : "0.5Gi")

      dynamic "env" {
        for_each = try(each.value.env_vars, {})
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = try(each.value.secrets, [])
        content {
          name        = env.value.name
          secret_name = env.value.secret_name
        }
      }
    }
  }

  dynamic "ingress" {
    for_each = try(each.value.ingress, null) != null ? [each.value.ingress] : []
    content {
      external_enabled = try(ingress.value.external_enabled, true)
      target_port      = ingress.value.target_port
      transport        = try(ingress.value.transport, "auto")

      dynamic "traffic_weight" {
        for_each = try(ingress.value.traffic_weight, null) != null ? [ingress.value.traffic_weight] : [{
          percentage      = 100
          latest_revision = true
        }]
        content {
          percentage      = traffic_weight.value.percentage
          latest_revision = try(traffic_weight.value.latest_revision, true)
        }
      }
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))

  # workload_profile_name은 Azure가 기본값(Consumption)으로 자동 설정하므로 변경 무시
  lifecycle {
    ignore_changes = [workload_profile_name]
  }
}

# Note: RBAC role assignment for Container Apps to access Key Vault should be done separately
# after Container Apps are created. Use Azure Portal or Azure CLI:
# az role assignment create --assignee <principal_id> --role "Key Vault Secrets User" --scope <key_vault_id>
