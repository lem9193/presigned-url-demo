locals {
  prefix             = "presigned-url-demo-provider"
  account_id         = data.aws_caller_identity.current.account_id
  cidr_block         = "10.0.0.0/16"
  ingress_cidr_block = "172.16.0.0/16"
  subnet_count       = 2
}

data "aws_caller_identity" "current" {}

module "network" {
  source             = "./module/network"
  prefix             = local.prefix
  cidr_block         = local.cidr_block
  ingress_cidr_block = local.ingress_cidr_block
  subnet_count       = local.subnet_count
  add_route          = var.add_route
}

module "route53" {
  source                     = "./module/route53"
  prefix                     = local.prefix
  resolver_security_group_id = module.network.resolver_security_group_id
  subnet_ids                 = module.network.subnet_ids
}

module "s3" {
  source     = "./module/s3"
  prefix     = local.prefix
  account_id = local.account_id
}

resource "null_resource" "upload_file" {
  provisioner "local-exec" {
    command = "aws s3 cp ./html/index.html s3://${module.s3.bucket_name}/index.html"
  }
}


output "vpc_id" {
  value = module.network.vpc_id
}

output "provider_account_id" {
  value = data.aws_caller_identity.current.account_id
}
