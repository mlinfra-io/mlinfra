module "kind" {
  source                 = "./kind_cluster"
  cluster_name           = var.cluster_name
  k8s_version            = var.k8s_version
  wait_for_control_plane = var.wait_for_control_plane
}

# TODO:
# Keeping this better fix here unless this issue gets resolved.
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1782
#
# data "http" "ingress_controller_file" {
#   url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
#   request_headers = {
#     Accept = "text/yaml"
#   }
#   depends_on = [module.kind]
# }

# locals {
#   ingress_controller_manifest = provider::kubernetes::manifest_decode_multi(data.http.ingress_controller_file.response_body)
# }

# resource "kubernetes_manifest" "ingress_controller" {
#   for_each = {
#     for manifest in local.ingress_controller_manifest :
#     "${manifest.kind}--${manifest.metadata.name}" => manifest
#   }
#   manifest = each.value
#   wait     = true
# }
