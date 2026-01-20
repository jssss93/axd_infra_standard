variable "key_vault_id" {
  description = "The ID of the Key Vault to store secrets"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# ACR variables
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
variable "cosmosdb_endpoint" {
  description = "Cosmos DB endpoint"
  type        = string
  default     = null
}

variable "cosmosdb_primary_key" {
  description = "Cosmos DB primary key"
  type        = string
  default     = null
  sensitive   = true
}

variable "cosmosdb_secondary_key" {
  description = "Cosmos DB secondary key"
  type        = string
  default     = null
  sensitive   = true
}

# PostgreSQL variables
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
variable "foundry_endpoint" {
  description = "Foundry endpoint"
  type        = string
  default     = null
}

# OpenAI variables
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
