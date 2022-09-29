resource "aviatrix_transit_gateway_peering" "aws_to_azure" {
  transit_gateway_name1 = module.aws_transit.mc_firenet_details.name
  transit_gateway_name2 = module.azure_transit.mc_firenet_details.name
}

resource "aviatrix_transit_gateway_peering" "aws_to_gcp" {
  transit_gateway_name1 = module.aws_transit.mc_firenet_details.name
  transit_gateway_name2 = module.gcp_transit.mc_firenet_details.name
}
