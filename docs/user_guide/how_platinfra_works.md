# User Guide

## How platinfra works

- A sample mlops stack looks something like this:
- The same stack can be configured to quite an extent:

=== "Simple Deployment Configuration"
    ```yaml
    name: simple-mlops-stack
    provider:
      name: aws
      account_id: "aws-12-digit-account-id"
      region: "aws-region"
    deployment:
      type: cloud_infra
    stack:
      - data_versioning:
          name: lakefs
      - experiment_tracking:
          name: mlflow
      - pipelining:
          name: prefect
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    name: simple-mlops-stack-advanced
    provider:
      name: aws
      account_id: "aws-12-digit-account-id"
      region: "aws-region"
    deployment:
      type: cloud_infra
    stack:
      - data_versioning:
          name: lakefs
          params:
            remote_tracking: true
            database_type: "dynamodb"
            lakefs_data_bucket_name: "lakefs-repository-data-bucket"
            dynamodb_table_name: "lakefs_kvstore"
      - experiment_tracking:
          name: mlflow
          params:
            remote_tracking: true
            mlflow_artifacts_bucket_name: "artifacts-storage-bucket"
      - pipelining:
          name: prefect
          params:
            remote_tracking: true
            ec2_application_port: 9500
    ```

## Stack file Composition

`platinfra` stack file is composed of 4 components:

- `name`: `name` denotes the name of the stack. This is used internally to identify the state of the the stack deployment.
- `provider` block:
    - `provider` block allows you to define where your stack gets deployed, whether it be local or on the cloud.
    - `account_id` and `region` are used to configure the cloud provider.
- `deployment` block:
    - `deployment` block defines the configuration of how the components get configured under the hood before deployment of mlops stack.
    - For now, `type` can be either `cloud_infra` or `kubernetes`. We're working to introduce more deployment types.
    - `type: cloud_infra` is used to deploy the stack to the cloud instances, whereas `kubernetes` uses cloud provider's kubernetes service to deploy the stack.
- `stack` block:
    - `stack` block defines the different application stacks that are deployed to the above mentioned `deployment` stack.
    - Each mlops stack is defined by a `name`. All stacks can be deployed from a simple name configuration to a more complex configuration where different components are
      deployed on cloud provider infrastructure components.
