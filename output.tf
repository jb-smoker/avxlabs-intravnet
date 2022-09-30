output "azure_application_public_address" {
  value = azurerm_public_ip.wp-fe.fqdn
}

output "azure_mysql_db_fqdn" {
  value = azurerm_mysql_flexible_server.default.fqdn
}

output "guacamole_url" {
  value = "https://${aws_instance.guacamole.public_ip}/#/index.html?username=${var.admin_username}&password=${var.admin_password}"
}

output "guacamole_username" {
  value = var.admin_username
}

output "guacamole_password" {
  value = var.admin_password
}

output "aws_mysql_db_fqdn" {
  value = aws_db_instance.wp_mysql.address
}

output "aws_web_server_ips" {
  value = [for v in module.ec2_instance_wp_web : v.private_ip]
}

output "aws_public_wp_url" {
  value = aws_lb.aws_wordpress_prod.dns_name
}

output "gcp_public_wp_ip" {
  value = google_compute_instance.wp_web.network_interface.0.access_config.0.nat_ip
}
