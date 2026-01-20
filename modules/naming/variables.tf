#===============================================================================
# Naming Module - Variables
#===============================================================================

variable "project_name" {
  description = "프로젝트 이름 (명명규칙의 첫 번째 요소)"
  type        = string
  default     = null
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
  default     = null
}

variable "purpose" {
  description = "용도/기능 (api, web, data 등)"
  type        = string
  default     = null
}

variable "asset_management" {
  description = "자산관리 코드 (선택)"
  type        = string
  default     = null
}

variable "sequence_number" {
  description = "순번 (001, 002 등)"
  type        = string
  default     = "001"
}

variable "custom_names" {
  description = "리소스별 커스텀 이름 (지정 시 자동 생성 이름보다 우선)"
  type = object({
    resource_group            = optional(string)
    vnet                      = optional(string)
    key_vault                 = optional(string)
    container_registry        = optional(string)
    cosmos_db                 = optional(string)
    postgresql                = optional(string)
    application_gateway       = optional(string)
    container_app_environment = optional(string)
    foundry                   = optional(string)
    openai                    = optional(string)
    log_analytics_workspace   = optional(string)
    storage_account           = optional(string)
    public_ip_agw             = optional(string)
  })
  default = {}
}
