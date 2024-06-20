locals {
  mlflow_helmchart_values = [{
    name  = "run.persistence.enabled"
    value = "true"
    type  = "auto"
  }]
}

module "mlflow_helmchart" {
  source = "../../../../../cloud/aws/helm_chart"

  name             = "mlflow"
  namespace        = "mlflow"
  create_namespace = true
  repository       = "oci://registry-1.docker.io/bitnamicharts/"
  chart            = "mlflow"
  chart_version    = var.mlflow_chart_version
  values = templatefile("${path.module}/values.yaml", {
    resources = jsonencode(var.resources)
  })
  set = local.mlflow_helmchart_values
}
