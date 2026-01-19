terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}
