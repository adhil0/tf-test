output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "region" {
  value       = var.region
  description = "region"
}

output "host" {
  value       = var.proxy_https_hosts[0]
  description = "host"
}

output "IP" {
  value       = data.kubernetes_service.IP.load_balancer_ingress.0.ip
}
