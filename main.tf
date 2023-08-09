terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "silverlord_rg" {
  name     = "silverlord-resource"
  location = "East Us"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "silverlord_vn" {
  name                = "silverlord_network"
  resource_group_name = azurerm_resource_group.silverlord_rg.name
  location            = azurerm_resource_group.silverlord_rg.location
  address_space       = ["10.123.123.0/24"]

  tags = {
    environment = "lab"
  }
}