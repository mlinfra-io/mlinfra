---
listen_address: "0.0.0.0:${ec2_application_port}"

database:
  type: "dynamodb"

auth:
  encrypt:
    secret_key: "${auth_secret_key}"

blockstore:
  type: s3
