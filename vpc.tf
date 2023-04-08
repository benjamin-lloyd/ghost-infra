module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = "ghost-app-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat
  enable_vpn_gateway = var.enable_vpn

  tags = local.account_tags

}
