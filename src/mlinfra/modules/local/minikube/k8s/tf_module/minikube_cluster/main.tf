resource "minikube_cluster" "cluster" {
  driver             = var.driver
  cluster_name       = var.cluster_name
  kubernetes_version = var.k8s_version
  nodes              = var.nodes

  addons = var.add_ons
}

resource "time_sleep" "cluster_creation" {
  create_duration = "30s"
  depends_on      = [minikube_cluster.cluster]
}
