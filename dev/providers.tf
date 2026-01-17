provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "eks" {
  count = var.deploy_app ? 1 : 0
  name  = module.eks_cluster.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  count = var.deploy_app ? 1 : 0
  name  = module.eks_cluster.cluster_name
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = var.deploy_app ? data.aws_eks_cluster.eks[0].endpoint : "https://127.0.0.1"
  cluster_ca_certificate = var.deploy_app ? base64decode(data.aws_eks_cluster.eks[0].certificate_authority[0].data) : ""
  token                  = var.deploy_app ? data.aws_eks_cluster_auth.eks[0].token : ""
}
