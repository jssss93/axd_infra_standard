variable "name" {
  description = "The name of the Private Endpoint"
  type        = string
}

variable "location" {
  description = "The Azure region where the Private Endpoint will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the Private Endpoint will be created"
  type        = string
}

variable "private_connection_resource_id" {
  description = "The ID of the Private Link Service or Azure resource that this Private Endpoint connects to"
  type        = string
}

variable "subresource_names" {
  description = "A list of subresource names which the Private Endpoint is able to connect to"
  type        = list(string)
}

variable "is_manual_connection" {
  description = "Does the Private Endpoint require Manual Approval from the remote resource owner?"
  type        = bool
  default     = false
}

variable "request_message" {
  description = "A message passed to the owner of the remote resource when the connection request is sent"
  type        = string
  default     = null
}

variable "private_service_connection_name" {
  description = "The name of the Private Service Connection (optional, auto-generated if not provided)"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of Private DNS Zone IDs to associate with the Private Endpoint"
  type        = list(string)
  default     = null
}

variable "private_dns_zone_group_name" {
  description = "The name of the Private DNS Zone Group (optional, auto-generated if not provided)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
