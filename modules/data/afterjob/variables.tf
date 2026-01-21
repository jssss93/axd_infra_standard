variable "key_vault_id" {
  description = "The ID of the Key Vault to store secrets"
  type        = string
  default     = null
}

variable "key_vault_enabled" {
  description = "Whether Key Vault is enabled"
  type        = bool
  default     = false
}

variable "create_secrets" {
  description = "Whether to create Key Vault secrets (can be disabled when Key Vault is private endpoint only)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# ACR variables
variable "container_registry_enabled" {
  description = "Whether Container Registry is enabled"
  type        = bool
  default     = false
}

variable "acr_login_server" {
  description = "ACR login server URL"
  type        = string
  default     = null
}

variable "acr_admin_username" {
  description = "ACR admin username"
  type        = string
  default     = null
  sensitive   = true
}

variable "acr_admin_password" {
  description = "ACR admin password"
  type        = string
  default     = null
  sensitive   = true
}

# Cosmos DB variables
variable "cdb_enabled" {
  description = "Whether Cosmos DB is enabled"
  type        = bool
  default     = false
}

variable "cdb_endpoint" {
  description = "Cosmos DB endpoint"
  type        = string
  default     = null
}

variable "cdb_primary_key" {
  description = "Cosmos DB primary key"
  type        = string
  default     = null
  sensitive   = true
}

variable "cdb_secondary_key" {
  description = "Cosmos DB secondary key"
  type        = string
  default     = null
  sensitive   = true
}

# PostgreSQL variables
variable "postgresql_enabled" {
  description = "Whether PostgreSQL is enabled"
  type        = bool
  default     = false
}

variable "postgresql_password" {
  description = "PostgreSQL administrator password"
  type        = string
  default     = null
  sensitive   = true
}

variable "postgresql_fqdn" {
  description = "PostgreSQL FQDN"
  type        = string
  default     = null
}

variable "postgresql_admin_login" {
  description = "PostgreSQL administrator login"
  type        = string
  default     = null
}

# Foundry variables
variable "foundry_enabled" {
  description = "Whether Foundry is enabled"
  type        = bool
  default     = false
}

variable "foundry_endpoint" {
  description = "Foundry endpoint"
  type        = string
  default     = null
}

# OpenAI variables
variable "openai_enabled" {
  description = "Whether OpenAI is enabled"
  type        = bool
  default     = false
}

variable "openai_endpoint" {
  description = "OpenAI endpoint"
  type        = string
  default     = null
}

variable "openai_primary_key" {
  description = "OpenAI primary access key"
  type        = string
  default     = null
  sensitive   = true
}

variable "openai_secondary_key" {
  description = "OpenAI secondary access key"
  type        = string
  default     = null
  sensitive   = true
}

variable "secret_names" {
  description = "Map of custom secret names (optional, overrides defaults)"
  type = object({
    acr_login_server       = optional(string)
    acr_admin_username     = optional(string)
    acr_admin_password     = optional(string)
    cosmosdb_endpoint      = optional(string)
    cosmosdb_primary_key   = optional(string)
    cosmosdb_secondary_key = optional(string)
    postgresql_password    = optional(string)
    postgresql_fqdn        = optional(string)
    postgresql_admin_login = optional(string)
    foundry_endpoint       = optional(string)
    openai_endpoint        = optional(string)
    openai_primary_key     = optional(string)
    openai_secondary_key   = optional(string)
  })
  default = null
}

variable "secret_content_type" {
  description = "Content type for Key Vault secrets (default: text/plain)"
  type        = string
  default     = null
}
