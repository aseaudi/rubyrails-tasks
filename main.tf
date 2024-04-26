# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }

  
}

provider "azurerm" {
  features {}
}

resource "azurerm_windows_virtual_machine" "main" {
  name                  = "aseaudi-vm"
  admin_username        = "azureuser"
  admin_password        = "pass"
  location              = "eastus"
  resource_group_name   = "RG_Simplex"
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }


}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "eastus"
}

