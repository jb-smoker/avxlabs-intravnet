resource "azurerm_subnet" "wp-bastion-subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_public_ip" "wp-bastion-vip" {
  name                = "bastionVip"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    application = "Bastion"
  }
}

resource "azurerm_bastion_host" "wp-bastion-host" {
  name                = "wordpress-bastion"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.wp-bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.wp-bastion-vip.id
  }
  tags = {
    application = "Bastion"
  }
}
