terraform {
  required_version = ">= 1.15.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

variable "postgres_password" {
  type = string
  sensitive = true
}

resource "kubernetes_namespace_v1" "arr" {
  metadata {
    name = "arr"
  }
}

resource "kubernetes_secret_v1" "postgres_password" {
  metadata {
    name = "sonarr-postgres-password"
    namespace = "arr"
  }

  data = {
    POSTGRES_PASSWORD = trimspace(var.postgres_password)
  }

  type = "Opaque"
}

resource "helm_release" "sonarr-db" {
  name = "sonarr"
  repository = "oci://ghcr.io/11notes/charts"
  chart = "postgres"
  namespace  = "arr"
  version = "1.0.0"

  values = [
    yamlencode({
      image = {
        tag: "18"
      }
      postgres = {
        existingSecret    = "sonarr-postgres-password"
        existingSecretKey = "POSTGRES_PASSWORD"
      }
      persistence = {
        etc = {
          size = "16Mi"
        }
        var = {
          size = "32Gi"
        }
      }
    })
  ]
}

resource "helm_release" "sonarr" {
  name = "sonarr"
  repository = "oci://ghcr.io/11notes/charts"
  chart = "sonarr"
  namespace  = "arr"
  version = "1.0.0"
  create_namespace = false

  values = [
    yamlencode({
      image = {
        tag: "4.0.19"
      }
      postgres = {
        existingSecret = "sonarr-postgres-password"
        existingSecretKey = "POSTGRES_PASSWORD"
        serviceName = "sonarr-postgres"
      }
      persistence = {
        etc = {
          size = "8Gi"
        }
      }
    })
  ]
}