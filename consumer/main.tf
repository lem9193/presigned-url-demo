locals {
  prefix                 = "presigned-url-demo-consumer"
  cidr_block             = "172.16.0.0/16"
  destination_cidr_block = "10.0.0.0/16"
  subnet_count           = 1
}

module "network" {
  source                 = "./module/network"
  prefix                 = local.prefix
  cidr_block             = local.cidr_block
  destination_cidr_block = local.destination_cidr_block
  subnet_count           = local.subnet_count
  peer_owner_id          = var.peer_owner_id
  peer_vpc_id            = var.peer_vpc_id
}

module "ec2" {
  source            = "./module/ec2"
  prefix            = local.prefix
  subnet_id         = module.network.subnet_ids[0]
  security_group_id = module.network.ec2_security_group_id
}
