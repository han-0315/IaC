terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
      App = "t101-nginx"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "t101-nginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "t101-nginx"
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30080
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}
