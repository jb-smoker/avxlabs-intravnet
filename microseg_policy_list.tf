# resource "aviatrix_microseg_policy_list" "microseg_policy_list_1" {
#     policies {
#         name = "Bastion"
#         action = "PERMIT"
#         src_app_domains = [ 
#             "239a3f13-0a4c-4b2f-b5aa-4326ec69c12e"
#         ]
#         dst_app_domains = [ 
#             "051decd7-cd49-4bd2-8208-1ff6bc3cd3c1"
#         ]
#         port_ranges {
#             lo = 22
#             hi = 0
#         }

#         port_ranges {
#             lo = 3389
#             hi = 0
#         }

#         protocol = "TCP"
#         logging = true
#         priority = 0
#         watch = false
#     }

#     policies {
#         name = "users-to-web"
#         action = "PERMIT"
#         src_app_domains = [ 
#             "051decd7-cd49-4bd2-8208-1ff6bc3cd3c1"
#         ]
#         dst_app_domains = [ 
#             "f9376863-96d7-4e6c-848d-4e105103cd49"
#         ]
#         port_ranges {
#             lo = 80
#             hi = 0
#         }

#         priority = 1
#         protocol = "TCP"
#         logging = true
#         watch = false
#     }

#     policies {
#         name = "web-to-db"
#         action = "PERMIT"
#         src_app_domains = [ 
#             "f9376863-96d7-4e6c-848d-4e105103cd49"
#         ]
#         dst_app_domains = [ 
#             "9bb40b8e-e046-44c8-8aa5-5123cb34a801"
#         ]
#         port_ranges {
#             lo = 3306
#             hi = 0
#         }

#         priority = 2
#         protocol = "TCP"
#         logging = true
#         watch = false
#     }

#     policies {
#         name = "CatchAll-WordpressVnet-Outbound"
#         action = "DENY"
#         src_app_domains = [ 
#             "42fe9203-6609-46ed-b525-395fb89f1f95"
#         ]
#         dst_app_domains = [ 
#             "051decd7-cd49-4bd2-8208-1ff6bc3cd3c1"
#         ]
#         priority = 3
#         logging = true
#         protocol = "ANY"
#         watch = false
#     }

#     policies {
#         name = "CatchAll-WordpressVnet-Inbound"
#         action = "DENY"
#         src_app_domains = [ 
#             "051decd7-cd49-4bd2-8208-1ff6bc3cd3c1"
#         ]
#         dst_app_domains = [ 
#             "42fe9203-6609-46ed-b525-395fb89f1f95"
#         ]
#         priority = 4
#         logging = true
#         protocol = "ANY"
#         watch = false
#     }

# }

