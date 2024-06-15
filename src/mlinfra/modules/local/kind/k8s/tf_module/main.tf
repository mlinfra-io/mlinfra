module "kind" {
  source                 = "./kind_cluster"
  cluster_name           = var.cluster_name
  k8s_version            = var.k8s_version
  wait_for_control_plane = var.wait_for_control_plane
}
