# Specifying minimum versions for Terraform and providers 
terraform {
  required_version = ">= 0.12"
  required_providers {
    helm       = ">= 1.2"
    google     = ">= 3.32"
    kubernetes = ">= 1.11"
  }
  
}
