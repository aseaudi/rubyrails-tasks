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

resource "random_pet" "prefix" {}

# Create virtual network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-${random_pet.prefix.id}"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "RG_Simplex"
}

# Create subnet
resource "azurerm_subnet" "example" {
  name                 = "subnet-${random_pet.prefix.id}"
  resource_group_name = "RG_Simplex"
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_postgresql_server" "example" {
  name                = "postgres-${random_pet.prefix.id}"
  location            = "eastus"
  resource_group_name = "RG_Simplex"

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "example" {
  name                = "exampledb"
  resource_group_name = "RG_Simplex"
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_service_plan" "example" {
  name                = "service-plan-${random_pet.prefix.id}"
  resource_group_name = "RG_Simplex"
  location            = "eastus"
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "example" {
  name                = "web-app-${random_pet.prefix.id}"
  resource_group_name = "RG_Simplex"
  location            = "eastus"
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                        = "keyvault-${random_pet.prefix.id}"
  location                    = "eastus"
  resource_group_name         = "RG_Simplex"
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_private_endpoint" "example" {
  name                = "key-vault-endpoint-${random_pet.prefix.id}"
  location                    = "eastus"
  resource_group_name         = "RG_Simplex"
  subnet_id           = azurerm_subnet.example.id

  private_service_connection {
    name                           = "example-privateserviceconnection-key-vault"
    private_connection_resource_id = azurerm_key_vault.example.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "example2" {
  name                = "linux-web-app-endpoint-${random_pet.prefix.id}"
  location                    = "eastus"
  resource_group_name         = "RG_Simplex"
  subnet_id           = azurerm_subnet.example.id

  private_service_connection {
    name                           = "example-privateserviceconnection-linux-web-app"
    private_connection_resource_id = azurerm_linux_web_app.example.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}
resource "azurerm_private_endpoint" "example3" {
  name                = "postgresal-server-endpoint-${random_pet.prefix.id}"
  location                    = "eastus"
  resource_group_name         = "RG_Simplex"
  subnet_id           = azurerm_subnet.example.id

  private_service_connection {
    name                           = "example-privateserviceconnection-postgresal-server"
    private_connection_resource_id = azurerm_postgresql_server.example.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "mydomain-${random_pet.prefix.id}.com"
  resource_group_name = "RG_Simplex"
}

resource "azurerm_private_dns_a_record" "example" {
  name                = "test-${random_pet.prefix.id}"
  zone_name           = azurerm_private_dns_zone.example.name
  resource_group_name = "RG_Simplex"
  ttl                 = 300
  records             = ["10.0.180.17"]
}




