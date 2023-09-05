terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.55"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~>1.8"
    }
  }
}

provider "azurerm" {
  features {}
}


provider "azapi" {
  # Configuration options
}
