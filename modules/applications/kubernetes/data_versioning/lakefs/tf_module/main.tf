module "lakefs_helmchart" {
  source = "../../../../../cloud/aws/helm_chart"

  name             = "lakefs"
  namespace        = "lakefs"
  create_namespace = true
  repository       = "https://charts.lakefs.io"
  chart            = "lakefs"
  chart_version    = "1.0.3"
  values           = file("${path.module}/values.yaml")
}
