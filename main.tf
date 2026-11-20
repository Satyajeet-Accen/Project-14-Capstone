terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "satyajeet_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = "satyajeet-eks-vpc"
  cidr                 = "10.14.0.0/16"
  azs                  = ["ap-south-1a", "ap-south-1b"]
  private_subnets      = ["10.14.1.0/24", "10.14.2.0/24"]
  public_subnets       = ["10.14.101.0/24", "10.14.102.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

module "satyajeet_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                             = "satyajeet-eks-cluster"
  cluster_version                          = "1.31"
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true # Grants your IAM user access

  vpc_id     = module.satyajeet_vpc.vpc_id
  subnet_ids = module.satyajeet_vpc.private_subnets

  eks_managed_node_groups = {
    satyajeet_nodes = {
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      instance_types = ["t3.medium"]
    }
  }
}
