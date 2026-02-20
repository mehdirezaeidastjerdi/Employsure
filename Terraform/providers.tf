terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id   = ""
  tenant_id         = ""
  client_id         = "fd7992b3-e2f9-494e-b891-7ff9da163321"
  client_secret     = ""
}



 