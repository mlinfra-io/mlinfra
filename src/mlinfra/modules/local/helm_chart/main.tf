resource "helm_release" "helm_chart" {
  name             = var.name
  namespace        = var.namespace
  create_namespace = var.create_namespace
  repository       = var.repository
  chart            = var.chart
  version          = var.chart_version
  cleanup_on_fail  = var.cleanup_on_fail
  atomic           = true
  values           = [var.values]

  dynamic "set" {
    for_each = var.set
    content {
      name  = set.value.name
      value = set.value.value
      type  = "auto"
    }
  }
}
