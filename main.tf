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
    environment = "lab"
  }
}

resource "azurerm_virtual_network" "silverlord_vn" {
  name                = "silverlord_network"
  resource_group_name = azurerm_resource_group.silverlord_rg.name
  location            = azurerm_resource_group.silverlord_rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "lab"
  }

}

resource "azurerm_subnet" "silverlord_sn" {
  name                 = "silverlord_subnet"
  resource_group_name  = azurerm_resource_group.silverlord_rg.name
  virtual_network_name = azurerm_virtual_network.silverlord_vn.name
  address_prefixes     = ["10.123.1.0/24"]

}

resource "azurerm_network_security_group" "silverlord_sg" {
  name                = "silverord_security_group"
  location            = azurerm_resource_group.silverlord_rg.location
  resource_group_name = azurerm_resource_group.silverlord_rg.name

  tags = {
    environment = "lab"
  }
}
resource "azurerm_network_security_rule" "silverlord_labrule" {
  name                        = "silverlord_labrule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.silverlord_rg.name
  network_security_group_name = azurerm_network_security_group.silverlord_sg.name
}

resource "azurerm_subnet_network_security_group_association" "silverlord-sga" {
  subnet_id                 = azurerm_subnet.silverlord_sn.id
  network_security_group_id = azurerm_network_security_group.silverlord_sg.id
}



resource "azurerm_public_ip" "silverlord_ip1" {
  name                = "silverlord_pubip"
  resource_group_name = azurerm_resource_group.silverlord_rg.name
  location            = azurerm_resource_group.silverlord_rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "lab"
  }
}

resource "azurerm_network_interface" "silverlord_ni1" {
  name                = "silverlord-ni1"
  location            = azurerm_resource_group.silverlord_rg.location
  resource_group_name = azurerm_resource_group.silverlord_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.silverlord_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.silverlord_ip1.id
  }
  tags = {
    environment = "lab"
  }
}

resource "azurerm_linux_virtual_machine" "silverlord_linux" {
  name                = "silverlord_linux"
  resource_group_name = azurerm_resource_group.silverlord_rg.name
  location            = azurerm_resource_group.silverlord_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.silverlord_ni1.id,
  ]

  custom_data = filebase64("Docker_build.sh")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/silverlordkey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  tags = {
    environment = "lab"
  }
}