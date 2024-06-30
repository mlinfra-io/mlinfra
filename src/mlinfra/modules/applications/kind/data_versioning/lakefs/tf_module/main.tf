module "lakefs_helmchart" {
  source = "../../../../../cloud/aws/helm_chart"

  name             = "lakefs"
  namespace        = "lakefs"
  create_namespace = true
  repository       = "https://charts.lakefs.io"
  chart            = "lakefs"
  chart_version    = var.lakefs_chart_version
  values = templatefile("${path.module}/values.yaml", {
    # nodeSelector = jsonencode(var.nodeSelector)
    # tolerations  = jsonencode(var.tolerations)
    # affinity     = jsonencode(var.affinity)
    resources       = jsonencode(var.resources)
    lakefs_endpoint = var.lakefs_endpoint
  })
  # set = concat(local.lakefs_helmchart_set, [{
  set = concat([], [{
    name  = "useDevPostgres"
    value = "true"
    type  = "auto"
  }])
}
