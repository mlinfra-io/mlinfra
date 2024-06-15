resource "kind_cluster" "local_kind_cluster" {
  name           = var.cluster_name
  node_image     = var.node_image[var.k8s_version]
  wait_for_ready = var.wait_for_control_plane

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # taken from:
      # https://kind.sigs.k8s.io/docs/user/ingress
      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
    }

    node {
      role = "worker"
    }
  }
}
