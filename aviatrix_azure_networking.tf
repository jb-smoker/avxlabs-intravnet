# module "azure_transit" {
#   source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
#   version = ">= 2.1.2"
#   # insert the 14 required variables here
#   name    = "azure-use-transit"
#   cloud   = "Azure"
#   account = "cmchenryAviatrix"
#   region  = "East US"
#   cidr    = "10.1.0.0/20"
#   enable_transit_firenet = false
#   ha_gw = false
# }

# module "azure_spoke_wordpress" {
#   source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
#   version = ">= 1.2.1"

#   cloud            = "Azure"
#   name             = "azure-use-spoke-wordpress"
#   region           = "East US"
#   account          = "cmchenryAviatrix"
#   transit_gw       = module.azure_transit.mc_firenet_details.name
#   use_existing_vpc = true
#   vpc_id           = "${azurerm_virtual_network.default.name}:${azurerm_virtual_network.default.resource_group_name}"
#   gw_subnet        = azurerm_subnet.wordpress-gateway.address_prefixes[0]
#   ha_gw = false
# }

# # resource "aviatrix_spoke_gateway_subnet_group" "web" {
# #   name = "backend"
# #   gw_name = module.azure_spoke_wordpress.spoke_gateway.gw_name
# #   subnets = ["${azurerm_subnet.web.address_prefixes[0]}~~${azurerm_subnet.web.name}"]
# # }

# # resource "aviatrix_spoke_gateway_subnet_group" "database" {
# #   name = "db"
# #   gw_name = module.azure_spoke_wordpress.spoke_gateway.gw_name
# #   subnets = ["${azurerm_subnet.database.address_prefixes[0]}~~${azurerm_subnet.database.name}"]
# # }

# # resource "aviatrix_spoke_gateway_subnet_group" "lb" {
# #   name = "frontend"
# #   gw_name = module.azure_spoke_wordpress.spoke_gateway.gw_name
# #   subnets = ["${azurerm_subnet.lb.address_prefixes[0]}~~${azurerm_subnet.lb.name}"]
# # }