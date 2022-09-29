module "aws_transit" {
  source                        = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version                       = ">= 2.1.2"
  name                          = "aws-transit"
  cloud                         = "AWS"
  account                       = var.aws_account_name
  region                        = var.aws_region
  cidr                          = "10.2.0.0/20"
  enable_transit_firenet        = true
  enable_egress_transit_firenet = false
  ha_gw                         = false
}

resource "aviatrix_gateway" "aws_egress_fqdn" {
  single_az_ha          = true
  gw_name               = "aws-egress-fqdn"
  vpc_id                = module.aws_transit.vpc.vpc_id
  cloud_type            = 1
  vpc_reg               = var.aws_region
  gw_size               = "t2.micro"
  account_name          = var.aws_account_name
  subnet                = module.aws_transit.vpc.public_subnets[1].cidr
  enable_encrypt_volume = true
  depends_on = [
    module.aws_transit
  ]
}

resource "aviatrix_firewall_instance_association" "egress_fqdn_association_1" {
  vpc_id          = module.aws_transit.vpc.vpc_id
  firenet_gw_name = module.aws_transit.transit_gateway.gw_name
  instance_id     = aviatrix_gateway.aws_egress_fqdn.gw_name
  vendor_type     = "fqdn_gateway"
  attached        = true
  depends_on = [
    aviatrix_gateway.aws_egress_fqdn
  ]
}


module "spoke_aws_ingress" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = ">= 1.2.1"

  cloud         = "AWS"
  name          = "spoke-aws-ingress"
  cidr          = "10.3.0.0/22"
  account       = var.aws_account_name
  region        = var.aws_region
  transit_gw    = module.aws_transit.transit_gateway.gw_name
  instance_size = "t2.micro"
  ha_gw         = false
}

module "spoke_aws_web" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = ">= 1.2.1"

  cloud         = "AWS"
  name          = "spoke-aws-web"
  cidr          = "10.3.4.0/22"
  account       = var.aws_account_name
  region        = var.aws_region
  transit_gw    = module.aws_transit.transit_gateway.gw_name
  instance_size = "t2.micro"
  ha_gw         = false
}

module "spoke_aws_db" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = ">= 1.2.1"

  cloud         = "AWS"
  name          = "spoke-aws-db"
  cidr          = "10.3.8.0/22"
  account       = var.aws_account_name
  region        = var.aws_region
  transit_gw    = module.aws_transit.transit_gateway.gw_name
  instance_size = "t2.micro"
  ha_gw         = false
}

resource "aws_route53_zone" "private" {
  name = "aws.useg.local"

  vpc {
    vpc_id = module.spoke_aws_db.vpc.vpc_id
  }
  vpc {
    vpc_id = module.spoke_aws_web.vpc.vpc_id
  }
  vpc {
    vpc_id = module.spoke_aws_ingress.vpc.vpc_id
  }
}

data "aws_route_table" "psf_public_rt1" {
  subnet_id = module.spoke_aws_ingress.vpc.public_subnets[0].subnet_id
}

data "aws_route_table" "psf_public_rt2" {
  subnet_id = module.spoke_aws_ingress.vpc.public_subnets[1].subnet_id
}

resource "aviatrix_gateway" "psf_aws" {
  cloud_type                                  = 1
  account_name                                = var.aws_account_name
  gw_name                                     = "spoke-aws-ingress-psf"
  vpc_id                                      = module.spoke_aws_ingress.vpc.vpc_id
  vpc_reg                                     = var.aws_region
  gw_size                                     = "t3.micro"
  subnet                                      = cidrsubnet(module.spoke_aws_ingress.vpc.cidr, 2, 1)
  zone                                        = "${var.aws_region}a"
  enable_public_subnet_filtering              = true
  public_subnet_filtering_route_tables        = [data.aws_route_table.psf_public_rt1.id, data.aws_route_table.psf_public_rt2.id]
  public_subnet_filtering_guard_duty_enforced = true
  single_az_ha                                = true
  enable_encrypt_volume                       = true
  lifecycle {
    ignore_changes = [public_subnet_filtering_route_tables]
  }
}
