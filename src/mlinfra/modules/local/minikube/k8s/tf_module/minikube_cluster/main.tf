resource "minikube_cluster" "cluster" {
  driver             = var.driver
  cluster_name       = var.cluster_name
  kubernetes_version = var.k8s_version
  nodes              = var.nodes
  wait               = var.wait_for_addons

  addons = var.add_ons
}

resource "time_sleep" "cluster_creation" {
  create_duration = "${var.wait_time}s"
  depends_on      = [minikube_cluster.cluster]
}
