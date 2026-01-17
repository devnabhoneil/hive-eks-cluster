data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  # Split /16 into /20s for a simple demo
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i)]
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, i + 8)]
}

# --- VPC (ancillary infrastructure) ---
module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "5.5.2"
  name            = "${var.name}-vpc"
  cidr            = var.vpc_cidr
  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  # Private nodes need egress to pull public images
  enable_nat_gateway = true
  single_nat_gateway = true

  # Needed for EKS LoadBalancer Services
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# --- EKS cluster ---
module "eks" {
  enable_cluster_creator_admin_permissions = true
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "20.8.4"
  cluster_name                             = "${var.name}-eks"
  cluster_version                          = var.cluster_version
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  cluster_endpoint_public_access           = true
  eks_managed_node_groups = {
    default = {
      name           = "${var.name}-mng"
      instance_types = var.node_instance_types
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      subnet_ids     = module.vpc.private_subnets
    }
  }

  access_entries = {
    terraform_user_admin = {
      principal_arn = data.aws_caller_identity.current.arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

# --- Kubernetes app deployment (separate child module, optional in phase-1) ---
module "k8s_app" {
  source         = "./k8s_app"
  count          = var.deploy_app ? 1 : 0
  cluster_name   = module.eks.cluster_name
  region         = var.region
  app_namespace  = var.app_namespace
  app_name       = var.app_name
  app_image      = var.app_image
  replicas       = var.replicas
  container_port = var.container_port
  service_port   = var.service_port

  providers = {
    aws        = aws
    kubernetes = kubernetes
  }

  depends_on = [module.eks]
}

