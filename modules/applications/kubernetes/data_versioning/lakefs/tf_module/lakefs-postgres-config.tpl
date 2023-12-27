secrets:
  authEncryptSecretKey: {auth_secret_key}
  databaseConnectionString: "postgresql://${db_instance_username}:${db_instance_password}@${db_instance_endpoint}/${db_instance_name}"

database:
  type: "postgres"

blockstore:
  type: s3
  s3:
    region: {region}
