# provider "guacamole" {
#   url                      = "https://${module.ec2_instance_guacamole.public_dns}"
#   username                 = "guacadmin"
#   password                 = regex("'(\\w{12})'\\.", ssh_resource.guac_password.result)[0]
#   disable_tls_verification = true
#   disable_cookies          = true
# }

# resource "guacamole_connection_group" "group_aws" {
#   parent_identifier = "ROOT"
#   name              = "AWS"
#   type              = "organizational"
#   attributes {
#     max_connections_per_user = 10
#   }
# }

# resource "guacamole_connection_group" "group_azure" {
#   parent_identifier = "ROOT"
#   name              = "Azure"
#   type              = "organizational"
#   attributes {
#     max_connections_per_user = 10
#   }
# }

# # resource "guacamole_connection_ssh" "azure_web" {
# #   count             = var.number_of_web_servers
# #   name              = "wp-be-${count.index}"
# #   parent_identifier = guacamole_connection_group.group_azure.identifier
# #   parameters {
# #     hostname = azurerm_network_interface.wp-web-interfaces[count.index].private_ip_address
# #     username = var.admin_username
# #     password = var.admin_password
# #     port     = 22
# #   }
# # }

# resource "guacamole_connection_ssh" "aws_web" {
#   count             = var.number_of_web_servers
#   name              = "wp-be-${count.index}"
#   parent_identifier = guacamole_connection_group.group_aws.identifier
#   parameters {
#     hostname    = module.ec2_instance_wp_web[count.index].private_ip
#     username    = "ec2-user"
#     private_key = module.key_pair.private_key_pem
#     port        = 22
#   }
#   depends_on = [
#     aviatrix_firewall_instance_association.egress_fqdn_association_1
#   ]
# }

# resource "guacamole_connection_rdp" "aws_vdi" {
#     name = "windows-vdi"
#     parent_identifier = guacamole_connection_group.group_aws.identifier
#     parameters {
#       hostname = module.ec2_instance_windows_vdi.private_ip
#       username = "Administrator"
#       password = rsadecrypt(module.ec2_instance_windows_vdi.password_data,module.key_pair.private_key_pem)
#       port = 3389
#       security_mode = "any"
#       ignore_cert = true
#     }
# }