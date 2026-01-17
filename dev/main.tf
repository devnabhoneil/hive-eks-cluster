module "eks_cluster" {
  source     = "../modules/eks_cluster"
  name       = var.name
  region     = var.region
  deploy_app = var.deploy_app

  providers = {
    aws        = aws
    kubernetes = kubernetes.eks
  }
}
