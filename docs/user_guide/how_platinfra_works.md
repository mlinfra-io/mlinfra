# User Guide

## How platinfra works

- A sample mlops stack looks something like this:
- The same stack can be configured to quite an extent:

=== "Simple Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/kubernetes/lakefs/aws-lakefs.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml
    --8<-- "docs/examples/kubernetes/lakefs/aws-lakefs-advanced.yaml"
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
