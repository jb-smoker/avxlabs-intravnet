module "gcp_transit" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = ">= 2.2.1"

  cloud   = "GCP"
  cidr    = "10.4.0.0/20"
  account = var.gcp_account_name
  region  = var.gcp_region
  ha_gw   = false
  name    = "gcp-transit"
}

# GCP Spokes
module "spoke_gcp_web" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = ">= 1.3.1"

  cloud      = "GCP"
  name       = "spoke-gcp-web"
  cidr       = "10.5.4.0/22"
  account    = var.gcp_account_name
  region     = var.gcp_region
  transit_gw = module.gcp_transit.transit_gateway.gw_name
  ha_gw      = false
}

module "spoke_gcp_db" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = ">= 1.3.1"

  cloud      = "GCP"
  name       = "spoke-gcp-db"
  cidr       = "10.5.8.0/22"
  account    = var.gcp_account_name
  region     = var.gcp_region
  transit_gw = module.gcp_transit.transit_gateway.gw_name
  ha_gw      = false
}
