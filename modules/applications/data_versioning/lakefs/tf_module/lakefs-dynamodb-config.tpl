---
listen_address: "0.0.0.0:${ec2_application_port}"

database:
  type: "dynamodb"
  dynamodb:
    table_name: ${dynamodb_table_name}
    aws_region: ${region}

auth:
  encrypt:
    secret_key: "${auth_secret_key}"

blockstore:
  type: s3
  s3:
    region: ${region}
