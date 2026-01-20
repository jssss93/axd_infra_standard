variable "environment" {
  description = "환경 이름 (필수) - 예: dev, staging, prod, nw, devops"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "프로젝트 이름 (필수)"
  type        = string
}

variable "purpose" {
  description = "용도/기능 (필수) - 예: main, dns, agent, cicd, search, nl2sql, chatbot, front, backend"
  type        = string
}

variable "asset_management" {
  description = "자산관리 (선택) - 예: resolver, pe, gitlab, runner, agw, cae, vm, aca"
  type        = string
  default     = null
}

variable "sequence_number" {
  description = "순번 (선택) - 예: 001, 002"
  type        = string
  default     = "001"
}

variable "resource_group_name" {
  description = "Resource Group 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "Virtual Network 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "container_app_environment_name" {
  description = "Container App Environment 이름 (선택, 지정하지 않으면 네이밍 규칙 자동 적용)"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "koreacentral"
}

variable "subscription_id" {
  description = "Azure Subscription ID (선택, 지정하지 않으면 기본 subscription 사용)"
  type        = string
  default     = null
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Subnet configurations"
  type = map(object({
    name                        = string
    address_prefixes            = list(string)
    network_security_group_id   = optional(string)
    route_table_id              = optional(string)
    service_endpoints           = optional(list(string))
    service_endpoint_policy_ids = optional(list(string))
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
}

variable "container_apps_subnet_id" {
  description = "Subnet key for Container Apps"
  type        = string
  default     = null
}

variable "container_apps" {
  description = "Container App configurations"
  type = map(object({
    name          = optional(string) # 명명규칙이 적용되면 자동 생성됨
    image         = string
    cpu           = optional(number, 0.25)
    memory        = optional(string, "0.5Gi")
    min_replicas  = optional(number, 0)
    max_replicas  = optional(number, 10)
    revision_mode = optional(string, "Single")
    env_vars      = optional(map(string), {})
    secrets = optional(list(object({
      name        = string
      secret_name = string
    })), [])
    ingress = optional(object({
      external_enabled = optional(bool, true)
      target_port      = number
      transport        = optional(string, "auto")
      traffic_weight = optional(object({
        percentage      = number
        latest_revision = optional(bool, true)
      }))
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics Workspace ID"
  type        = string
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  type        = string
  default     = null
}

variable "log_analytics_workspace_suffix" {
  description = "Log Analytics Workspace suffix"
  type        = string
  default     = "laws"
}

variable "log_analytics_workspace_sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Log Analytics retention days"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
