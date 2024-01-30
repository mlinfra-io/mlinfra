database:
  type: "dynamodb"
  dynamodb:
    table_name: ${dynamodb_table_name}
    aws_region: ${region}

blockstore:
  type: s3
  s3:
    region: ${region}
