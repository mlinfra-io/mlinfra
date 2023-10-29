output "eks_cluster_name" {
  value = module.eks.cluster_name
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
