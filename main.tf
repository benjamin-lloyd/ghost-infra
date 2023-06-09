terraform {

  cloud {
    organization = "benjamin-lloyd-personal"

    workspaces {
      name = "ghost-infra"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.61.0"
    }
  }

  required_version = ">= 1.1.0"

}

provider "aws" {
    region  = "eu-central-1"
}

provider "aws" {
    alias   = "secondary"
    region  = "eu-west-1"
}


