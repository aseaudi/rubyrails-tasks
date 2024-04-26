# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "aseaudi-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "RG_Simplex"
}






