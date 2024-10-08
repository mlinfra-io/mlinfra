module "lakefs_helmchart" {
  source = "../../../../../local/helm_chart"

  name             = "lakefs"
  namespace        = "lakefs"
  create_namespace = true
  repository       = "https://charts.lakefs.io"
  chart            = "lakefs"
  chart_version    = var.lakefs_chart_version
  values = templatefile("${path.module}/values.yaml", {
    resources       = jsonencode(var.resources)
    lakefs_endpoint = var.lakefs_endpoint
  })

  set = concat([], [{
    name  = "useDevPostgres"
    value = "true"
    type  = "auto"
  }])
}
