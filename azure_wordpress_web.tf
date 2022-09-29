resource "azurerm_network_interface" "wp-web-interfaces" {
  count = var.number_of_web_servers

  name                = "wp-be-nic-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "wp-be-nic-config-${count.index}"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "wp-web-vms" {
  count = var.number_of_web_servers

  name                             = "wp-be-${count.index}"
  location                         = replace(lower(var.azure_region), " ", "-")
  resource_group_name              = azurerm_resource_group.default.name
  network_interface_ids            = [azurerm_network_interface.wp-web-interfaces[count.index].id]
  vm_size                          = "Standard_DS1_v2"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "wp-os-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "wp-be-${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = data.cloudinit_config.config.rendered
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = var.tags
}

data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "web.conf"
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/azure_web.tftpl", { db_fqdn = "${azurerm_mysql_flexible_server.default.fqdn}", db_user = "${var.database_admin_login}", db_password = "${var.database_admin_password}" })
  }
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.default.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.default.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.default.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.default.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.default.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.default.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.default.name}-rdrcfg"
}


resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc01" {
  count                   = var.number_of_web_servers
  network_interface_id    = azurerm_network_interface.wp-web-interfaces[count.index].id
  ip_configuration_name   = "wp-be-nic-config-${count.index}"
  backend_address_pool_id = tolist(azurerm_application_gateway.wp-appgateway.backend_address_pool).0.id
}

resource "azurerm_public_ip" "wp-fe" {
  name                = "wordpress-public-ip"
  location            = replace(lower(var.azure_region), " ", "-")
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Dynamic"
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}


resource "azurerm_application_gateway" "wp-appgateway" {
  name                = "wp-appgateway"
  resource_group_name = azurerm_resource_group.default.name
  location            = replace(lower(var.azure_region), " ", "-")

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.frontend_ip_configuration_name
    subnet_id = azurerm_subnet.lb.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.wp-fe.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  # backend_address_pool {
  #   name = "wp-fe-ips"
  #   ip_addresses = [for v in azurerm_network_interface.wp-web-interfaces : v.private_ip_address]
  # }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}


