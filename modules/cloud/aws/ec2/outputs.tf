output "public_ip" {
  # This can return null if the instance is not yet available in case of a spot request.
  value = module.ec2_instance.public_ip == null ? "Please check for address on AWS Console or re-apply this module." : "http://${module.ec2_instance.public_ip}"
}

output "public_dns" {
  # This can return null if the instance is not yet available in case of a spot request.
  value = module.ec2_instance.public_dns == null ? "Please check for address on AWS Console or re-apply this module." : "http://${module.ec2_instance.public_dns}"
}
