# resource "aviatrix_app_domain" "app_domain_1" {
#     name = "Any"
#     selector {
#         match_expressions {
#             cidr = "0.0.0.0/0"
#         }

#     }

# }

# resource "aviatrix_app_domain" "app_domain_2" {
#     name = "AzureWordpressFrontEnd"
#     selector {
#         match_expressions {
#             cidr = "10.0.2.0/24"
#         }

#     }

# }

# resource "aviatrix_app_domain" "app_domain_3" {
#     name = "AzureWordpressDatabase"
#     selector {
#         match_expressions {
#             cidr = "10.0.3.0/24"
#         }

#     }

# }

# resource "aviatrix_app_domain" "app_domain_4" {
#     name = "AzureWordpressVnet"
#     selector {
#         match_expressions {
#             cidr = "10.0.0.0/16"
#         }

#     }

# }

# resource "aviatrix_app_domain" "app_domain_5" {
#     name = "AWSBastion"
#     selector {
#         match_expressions {
#             type = "vm"
#             tags = {
#                     Application = "Bastion"
#                 }
#         }

#     }

# }

