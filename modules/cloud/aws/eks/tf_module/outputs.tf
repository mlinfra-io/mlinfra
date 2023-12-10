output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca_cert" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}
