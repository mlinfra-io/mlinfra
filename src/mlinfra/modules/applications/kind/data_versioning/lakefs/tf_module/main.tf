# locals {
#   lakefs_config_filename = ""
#   lakefs_config = templatefile("${path.module}/${local.lakefs_config_filename}", {
#     dynamodb_table_name = var.dynamodb_table_name
#     region              = data.aws_region.current.name
#   })
#   lakefs_helmchart_set = [{
#     name  = "lakefsConfig"
#     value = "${local.lakefs_config}"
#     type  = "auto"
#   }]
# }

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
    resources = jsonencode(var.resources)
  })
  # set = concat(local.lakefs_helmchart_set, [{
  set = concat([], [{
    name  = "useDevPostgres"
    value = "true"
    type  = "auto"
  }])
}
