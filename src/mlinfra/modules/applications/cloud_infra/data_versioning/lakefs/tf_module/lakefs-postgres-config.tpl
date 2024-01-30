---
listen_address: "0.0.0.0:${ec2_application_port}"

database:
  type: "postgres"
  postgres:
    connection_string: "postgresql://${db_instance_username}:${db_instance_password}@${db_instance_endpoint}/${db_instance_name}"

auth:
  encrypt:
    secret_key: "${auth_secret_key}"

blockstore:
  type: s3
  s3:
    region: ${region}
