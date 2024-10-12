module "minikube" {
  source = "./minikube_cluster"

  driver          = var.driver
  cluster_name    = var.cluster_name
  k8s_version     = var.k8s_version
  nodes           = var.nodes
  add_ons         = var.add_ons
  wait_for_addons = var.wait_for_addons
  wait_time       = var.wait_time
}
