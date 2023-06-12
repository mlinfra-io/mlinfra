output "mlflow_server_address" {
  value = "http://${module.mlflow_application.public_ip}"
}
