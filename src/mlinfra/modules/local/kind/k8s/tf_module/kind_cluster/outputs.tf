output "endpoint" {
  value       = kind_cluster.local_kind_cluster.endpoint
  description = ""
}

output "client_certificate" {
  value       = kind_cluster.local_kind_cluster.client_certificate
  description = ""
}

output "cluster_ca_certificate" {
  value       = kind_cluster.local_kind_cluster.cluster_ca_certificate
  description = ""
}

output "client_key" {
  value = kind_cluster.local_kind_cluster.client_key
}

output "kubeconfig" {
  value       = kind_cluster.local_kind_cluster.kubeconfig
  description = ""
}
