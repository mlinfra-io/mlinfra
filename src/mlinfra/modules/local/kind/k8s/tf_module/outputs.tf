output "kind_endpoint" {
  value       = kind_cluster.local_kind_cluster.endpoint
  description = ""
}

output "kind_client_certificate" {
  value       = kind_cluster.local_kind_cluster.client_certificate
  description = ""
}

output "kind_cluster_ca_certificate" {
  value       = kind_cluster.local_kind_cluster.cluster_ca_certificate
  description = ""
}

output "kind_client_key" {
  value = kind_cluster.local_kind_cluster.client_key
}

output "kind_kubeconfig" {
  value       = kind_cluster.local_kind_cluster.kubeconfig
  description = ""
}
