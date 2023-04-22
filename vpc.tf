module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = "ghost-app-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat
  enable_vpn_gateway = var.enable_vpn

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.account_tags

}

resource "aws_security_group" "ghost_cw_endpoint_sg" {
  name = "ghost-app-sg-cw-endpoint-${var.environment}"
  description = "Security Group for CW access from ECS via endpoint"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.ghost_ecs_sg.id]
  }
  egress {
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    security_groups = [aws_security_group.ghost_ecs_sg.id]
  }
}

resource "aws_vpc_endpoint" "ghost_cw_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-central-1.logs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ghost_cw_endpoint_sg.id,
  ]

  subnet_ids        = module.vpc.private_subnets

  private_dns_enabled = true

  tags = "${
             merge(local.account_tags,
             {
               Name    =  "ghost-cw-endpoint-${var.environment}"
             }
            )
  }"
}
