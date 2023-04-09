# Core Configuration
environment       =   "dev1"
region            =   "eu-central-1"
secondary_region  =   "eu-west-1"

# Networking Configuration
vpc_cidr           =   "10.0.0.0/18"
availability_zones =   ["eu-central-1a","eu-central-1b","eu-central-1c"]
private_subnets    =   ["10.0.0.0/21","10.0.8.0/21","10.0.16.0/21"]
public_subnets     =   ["10.0.32.0/21","10.0.40.0/21","10.0.48.0/21"]
enable_nat         =   true
enable_vpn         =   false

# ECS Configuration
desired_cpu       =    256
desired_memory    =    512
host_port         =    2368

# Budgets Configuration
budget_limit     =    200
cost_subscriber_emails = ["blloyd67@gmail.com"]

#Additional Tag Configuration

