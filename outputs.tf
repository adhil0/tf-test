output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "region" {
  value       = var.region
  description = "region"
}

output "host" {
  value       = var.proxy_https_hosts
  description = "host"
}