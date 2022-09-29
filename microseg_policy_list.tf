resource "aviatrix_microseg_policy_list" "microseg_policy_list_1" {
  policies {
    name   = "Bastion"
    action = "PERMIT"
    src_app_domains = [
      aviatrix_app_domain.app_domain_1.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.app_domain_5.uuid
    ]
    port_ranges {
      lo = 22
      hi = 0
    }

    port_ranges {
      lo = 3389
      hi = 0
    }

    protocol = "TCP"
    logging  = true
    priority = 0
    watch    = false
  }

  policies {
    name   = "users-to-web"
    action = "PERMIT"
    src_app_domains = [
      aviatrix_app_domain.app_domain_5.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.app_domain_3.uuid
    ]
    port_ranges {
      lo = 80
      hi = 0
    }

    priority = 1
    protocol = "TCP"
    logging  = true
    watch    = false
  }

  policies {
    name   = "web-to-db"
    action = "PERMIT"
    src_app_domains = [
      aviatrix_app_domain.app_domain_2.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.app_domain_3.uuid
    ]
    port_ranges {
      lo = 3306
      hi = 0
    }

    priority = 2
    protocol = "TCP"
    logging  = true
    watch    = false
  }

  policies {
    name   = "CatchAll-WordpressVnet-Outbound"
    action = "DENY"
    src_app_domains = [
      aviatrix_app_domain.app_domain_4.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.app_domain_1.uuid
    ]
    priority = 3
    logging  = true
    protocol = "ANY"
    watch    = false
  }

  policies {
    name   = "CatchAll-WordpressVnet-Inbound"
    action = "DENY"
    src_app_domains = [
      aviatrix_app_domain.app_domain_1.uuid
    ]
    dst_app_domains = [
      aviatrix_app_domain.app_domain_4.uuid
    ]
    priority = 4
    logging  = true
    protocol = "ANY"
    watch    = false
  }

}

