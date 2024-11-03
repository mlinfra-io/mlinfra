resource "random_password" "mlflow_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>"
}

locals {
  mlflow_helmchart_values = [{
    name  = "run.persistence.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "tracking.auth.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "tracking.ingress.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "tracking.readinessProbe.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "tracking.ingress.hostname"
    value = var.mlflow_endpoint
    type  = "auto"
    }, {
    name  = "run.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "tracking.service.type"
    value = "ClusterIP"
    type  = "auto"
    }, {
    name  = "postgresql.auth.password"
    value = "${random_password.mlflow_password.result}"
    type  = "auto"
    }, {
    name  = "postgresql.volumePermissions.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "minio.volumePermissions.enabled"
    value = "true"
    type  = "auto"
  }]
}

module "mlflow_helmchart" {
  source = "../../../../../local/helm_chart"

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
