output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "gcp_project" {
  value       = var.gcp_project
  description = "GCloud project"
}

output "credentials_file" {
  value       = var.gcp_credentials_file
  description = "GCloud credentials_file"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}
