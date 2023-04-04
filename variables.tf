#Core Configuration
variable "environment" {
  type           =    string
  description    =    "This variable defines the environment in which infrastructure resources will be deployed"
}

variable "region" {
  type           =    string
  description    =    "This variable defines the region in which infrastructure resources will be deployed"
}

variable "secondary_region" {
  type           =    string
  description    =    "This variable defines the secondary region in which infrastructure resources will be deployed in case of DR failover"
}


#Networking Configuration
variable "vpc_cidr" {
  type           =    string
  description    =    "This variable defines the CIDR range for the VPC"
}

variable "private_subnets" {
  type           =    list(string)
  description    =    "This variable defines a list of private subnets with associated CIDR range"
}

variable "public_subnets" {
  type           =    list(string)
  description    =    "This variable defines a list of public subnets with associated CIDR range"
}

variable "enable_nat" {
  type           =    bool
  description    =    "This variable defines whether to deploy a NAT gateway in private subnets"
}

variable "enable_vpn" {
  type           =    bool
  description    =    "This variable defines whether to deploy a VPN gateway in the VPC"
}

