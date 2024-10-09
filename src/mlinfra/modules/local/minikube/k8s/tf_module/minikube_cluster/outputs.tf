output "endpoint" {
  value       = minikube_cluster.cluster.host
  description = "The endpoint of the Minikube cluster"
}

output "client_certificate" {
  value       = minikube_cluster.cluster.client_certificate
  description = "The client certificate for accessing the Minikube cluster"
  sensitive   = true
}

output "cluster_ca_certificate" {
  value       = minikube_cluster.cluster.cluster_ca_certificate
  description = "The CA certificate for the Minikube cluster"
  sensitive   = true
}

output "client_key" {
  value       = minikube_cluster.cluster.client_key
  description = "The client key for accessing the Minikube cluster"
  sensitive   = true
}
