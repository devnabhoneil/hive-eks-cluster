output "region" {
  value = var.region
}

output "cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "service_url" {
  value = module.eks_cluster.service_url
}
