data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

resource "kubernetes_namespace" "ns" {
  metadata { name = var.app_namespace }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.ns.metadata[0].name
    labels    = { app = var.app_name }
  }

  spec {
    replicas = var.replicas

    selector { match_labels = { app = var.app_name } }

    template {
      metadata { labels = { app = var.app_name } }

      spec {
        container {
          name  = var.app_name
          image = var.app_image

          port { container_port = var.container_port }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  spec {
    selector = { app = var.app_name }

    port {
      port        = var.service_port
      target_port = var.container_port
    }

    type = "LoadBalancer"
  }
}
