output "endpoint" {
  value       = module.minikube.endpoint
  description = "The endpoint of the Minikube cluster"
}

output "client_certificate" {
  value       = module.minikube.client_certificate
  description = "The client certificate for accessing the Minikube cluster"
  sensitive   = true
}

output "cluster_ca_certificate" {
  value       = module.minikube.cluster_ca_certificate
  description = "The CA certificate for the Minikube cluster"
  sensitive   = true
}

output "client_key" {
  value       = module.minikube.client_key
  description = "The client key for accessing the Minikube cluster"
  sensitive   = true
}
