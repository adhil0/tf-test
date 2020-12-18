terraform {
  required_version = ">= 0.13"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 1.2"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 3.32"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11"
    }
  }

}