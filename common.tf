# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "tfrg" {
    name     = "${var.prefix}-rg"
    location = var.location

    tags = {
        environment = var.tag
    }
}

/*
# Create virtual network
resource "azurerm_virtual_network" "tfvnet" {
    name                = "${var.prefix}-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.tfrg.name

    tags = {
        environment = "${var.tag}"
    }
}

resource "azurerm_subnet" "tfnatvnet" {
  name                 = "app-natnet"
  virtual_network_name = azurerm_virtual_network.tfvnet.name
  resource_group_name  = azurerm_resource_group.tfrg.name
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "tfwebvnet" {
  name                 = "web-subnet"
  virtual_network_name = azurerm_virtual_network.tfvnet.name
  resource_group_name  = azurerm_resource_group.tfrg.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "tfappvnet" {
  name                 = "app-subnet"
  virtual_network_name = azurerm_virtual_network.tfvnet.name
  resource_group_name  = azurerm_resource_group.tfrg.name
  address_prefix       = "10.0.2.0/24"
}
*/