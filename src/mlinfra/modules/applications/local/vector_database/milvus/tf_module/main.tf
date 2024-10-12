locals {
  milvus_helmchart_set = [{
    name  = "cluster.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "pulsar.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "etcd.replicaCount"
    value = "1"
    type  = "auto"
    }, {
    name  = "minio.mode"
    value = "standalone"
    type  = "auto"
    }, {
    name  = "ingress.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "ingress.rules[0].host"
    value = "milvus.localhost"
    type  = "auto"
    }, {
    name  = "ingress.rules[0].path"
    value = "/"
    type  = "auto"
    }, {
    name  = "ingress.rules[0].pathType"
    value = "Prefix"
    type  = "auto"
    }, {
    name  = "attu.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "attu.ingress.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "attu.ingress.hosts[0]"
    value = var.milvus_endpoint
    type  = "auto"
    }, {
    name  = "etcd.volumePermissions.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "minio.securityContext.enabled"
    value = "false"
    type  = "auto"
  }]
}

module "milvus_helmchart" {
  source           = "../../../../../local/helm_chart"
  name             = "milvus"
  namespace        = "milvus"
  create_namespace = true
  repository       = "https://zilliztech.github.io/milvus-helm/"
  chart            = "milvus"
  chart_version    = var.milvus_chart_version
  values = templatefile("${path.module}/values.yaml", {
    resources = jsonencode(var.resources)
  })
  set = local.milvus_helmchart_set
}
