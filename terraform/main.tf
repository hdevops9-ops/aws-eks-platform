data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  name = "platform-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"
  name    = local.name
  cidr    = "10.40.0.0/16"
  azs     = local.azs

  private_subnets = ["10.40.0.0/20", "10.40.16.0/20"]
  public_subnets  = ["10.40.128.0/24", "10.40.129.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment == "lab"
  one_nat_gateway_per_az = var.environment != "lab"
  enable_dns_hostnames   = true
  public_subnet_tags     = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags    = { "kubernetes.io/role/internal-elb" = "1" }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.0.3"

  name               = local.name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets

  endpoint_private_access = true
  endpoint_public_access  = false
  enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  addons = {
    vpc-cni = {
      before_compute = true
    }
    coredns    = {}
    kube-proxy = {}
  }

  access_entries = {
    administrator = {
      principal_arn = var.administrator_role_arn
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }
  eks_managed_node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      capacity_type  = "ON_DEMAND"
      labels         = { workload = "general" }
    }
  }
}
