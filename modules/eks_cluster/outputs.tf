output "region" {
  value = var.region
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "service_url" {
  value = try(module.k8s_app[0].service_url, "")
}


