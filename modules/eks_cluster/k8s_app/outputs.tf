output "service_url" {
  value = try("http://${kubernetes_service.svc.status[0].load_balancer[0].ingress[0].hostname}", "")
}
