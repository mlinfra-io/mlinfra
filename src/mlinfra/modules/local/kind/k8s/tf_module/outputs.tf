output "endpoint" {
  value       = module.kind.endpoint
  description = ""
}

output "client_certificate" {
  value       = module.kind.client_certificate
  description = ""
}

output "cluster_ca_certificate" {
  value       = module.kind.cluster_ca_certificate
  description = ""
}

output "client_key" {
  value = module.kind.client_key
}

output "kubeconfig" {
  value       = module.kind.kubeconfig
  description = ""
}
