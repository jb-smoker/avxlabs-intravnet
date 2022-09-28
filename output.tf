# output "azure_application_public_address" {
#   value = azurerm_public_ip.wp-fe.fqdn
# }

# output "azure_mysql_db_fqdn" {
#   value = azurerm_mysql_flexible_server.default.fqdn
# }

output "guacamole_url" {
  value = "https://${module.ec2_instance_guacamole.public_dns}/#/index.html?username=guacadmin&password=${regex("'(\\w{12})'\\.", ssh_resource.guac_password.result)[0]}"
}

output "guacamole_username" {
  value = "guacadmin"
}

output "guacamole_password" {
 value = regex("'(\\w{12})'\\.", ssh_resource.guac_password.result)[0]
}

output "aws_mysql_db_fqdn"{
  value = aws_db_instance.wp_mysql.address
}

output "aws_web_server_ips" {
  value = [for v in module.ec2_instance_wp_web : v.private_ip]
}

output "aws_public_wp_url" {
  value = aws_lb.aws_wordpress_prod.dns_name
}