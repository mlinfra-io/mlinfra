output "dagster_server_address" {
  # This can return null if the instance is not yet available in case of a spot request.
  value = module.dagster.public_ip == null ? "Please check for address on AWS Console or re-apply this module." : module.dagster.public_ip
}

output "dagster_server_dns_address" {
  # This can return null if the instance is not yet available in case of a spot request.
  value = module.dagster.public_dns == null ? "Please check for address on AWS Console or re-apply this module." : module.dagster.public_dns
}
