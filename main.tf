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

resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "aseaudi-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "RG_Simplex"
}

resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "aseaudi-subnet"
  resource_group_name  = "RG_Simplex"
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "aseaudi-nic"
  location            = "eastus"
  resource_group_name = "RG_Simplex"

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                  = "aseaudi-vm"
  admin_username        = "azureuser"
  admin_password        = "pass"
  location              = "eastus"
  resource_group_name   = "RG_Simplex"
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
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

