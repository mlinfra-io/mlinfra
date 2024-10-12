locals {
  prefect_server_helmchart_values = [{
    name  = "postgresql.useSubChart"
    value = "true"
    type  = "auto"
    }, {
    name  = "postgresql.primary.persistence.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "postgresql.volumePermissions.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "ingress.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "ingress.host.hostname"
    value = "${var.prefect_server_hostname}"
    type  = "auto"
  }]
}

module "prefect_server_helmchart" {
  source = "../../../../../local/helm_chart"

  name             = "prefect-server"
  namespace        = var.namespace
  create_namespace = true
  repository       = "https://prefecthq.github.io/prefect-helm"
  chart            = "prefect-server"
  chart_version    = var.prefect_chart_version
  values = templatefile("${path.module}/values.yaml", {
    prefect_deplyoment_type = "server"
    resources               = jsonencode(var.resources)
  })
  set = concat(local.prefect_server_helmchart_values, [{
    name  = "postgresql.enabled"
    value = "true"
    type  = "auto"
  }])
}



locals {
  prefect_worker_helmchart_values = [{
    name  = "worker.apiConfig"
    value = "server"
    type  = "auto"
    }, {
    name  = "worker.config.workPool"
    value = "Kubernetes-workpool"
    type  = "auto"
    }, {
    name  = "worker.serverApiConfig.apiUrl"
    value = "http://prefect-server.${var.namespace}.svc.cluster.local:4200/api"
    type  = "auto"
  }]
}

module "prefect_worker_helmchart" {
  source = "../../../../../local/helm_chart"

  name             = "prefect-worker"
  namespace        = var.namespace
  create_namespace = false
  repository       = "https://prefecthq.github.io/prefect-helm"
  chart            = "prefect-worker"
  chart_version    = var.prefect_chart_version
  values = templatefile("${path.module}/values.yaml", {
    prefect_deplyoment_type = "worker"
    resources               = jsonencode(var.resources)
  })
  set        = local.prefect_worker_helmchart_values
  depends_on = [module.prefect_server_helmchart]
}
