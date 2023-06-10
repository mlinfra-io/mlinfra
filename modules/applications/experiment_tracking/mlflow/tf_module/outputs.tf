output "mlflow_server_address" {
  value = "http://${module.mlflow.public_ip}"
}
