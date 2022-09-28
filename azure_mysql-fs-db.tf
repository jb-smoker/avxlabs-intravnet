# // Manages the MySQL Flexible Server Database
# // Manages the MySQL Flexible Server
# resource "azurerm_mysql_flexible_server" "default" {
#   name                         = "mysqlfs-${random_string.name.result}"
#   resource_group_name          = azurerm_resource_group.default.name
#   location                     = azurerm_resource_group.default.location
#   administrator_login          = var.database_admin_login
#   administrator_password       = var.database_admin_password
#   zone                         = "1"
#   version                      = "5.7"
#   backup_retention_days        = 7
#   geo_redundant_backup_enabled = false

#   storage {
#     size_gb = 20
#     iops    = 360
#   }

#   delegated_subnet_id = azurerm_subnet.database.id
#   private_dns_zone_id = azurerm_private_dns_zone.default.id
#   sku_name            = "GP_Standard_D2ds_v4"

#   high_availability {
#     mode                      = "ZoneRedundant"
#     standby_availability_zone = "2"
#   }

#   maintenance_window {
#     day_of_week  = 0
#     start_hour   = 8
#     start_minute = 0
#   }

#   depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
# }

# resource "azurerm_mysql_flexible_database" "default" {
#   name                = "mysqlfsdb_${random_string.name.result}"
#   resource_group_name = azurerm_resource_group.default.name
#   server_name         = azurerm_mysql_flexible_server.default.name
#   charset             = "utf8"
#   collation           = "utf8_unicode_ci"
# }

