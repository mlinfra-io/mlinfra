### Using mlinfra

`mlinfra` is used as a cli which always takes `--stack-config-path` as an argument which is the path ofg the stack file that represents your MLOps stacks and deployment type. Following functions can be performed on a stack file:

!!! note "Cloud Credentials"

    `mlinfra` relies on cloud credentials to be configured prior to all these commands getting executed.

- `estimate-cost`: This command generates a cost breakdown of the cloud components defined in the stack config file. To use this feature, `infracost` needs to be [installed](https://www.infracost.io/docs/#1-install-infracost) on your system. An example is as follows:
```bash
mlinfra estimate-cost --stack-config-path=aws-lakefs-k8s.yaml
```
- `generate-terraform-config`: This command generates the `*.tf.json` configuration for the stack file and allows the user to inspect the params prior to getting deployed. An example is as follows:
```bash
mlinfra generate-terraform-config --stack-config-path=aws-lakefs-k8s.yaml
```
- `terraform`: This command is used in conjunction with another sub-command `--apply` which has the following values:

    - `plan`: used to plan the stack config
    - `apply`: used to apply the stack config
    - `destroy`: used to destroy / delete the stack config

- Examples of these commands are as follows:
```bash
# To plan the changes in a stack config
mlinfra terraform --action=plan --stack-config-path=aws-lakefs-k8s.yaml

# To apply the stack config components
mlinfra terraform --action=apply --stack-config-path=aws-lakefs-k8s.yaml

# To delete the stack config components
mlinfra terraform --action=destroy --stack-config-path=aws-lakefs-k8s.yaml
```

!!! info
    As the tool is under active development, more commands might be added to `mlinfra` based on users requests that might facilitate ease of operations.

### Deploying a Stack

- A sample mlops stack for deployment on Cloud IaaS looks as follows:

===+ "Simple Deployment Configuration"
    ```yaml title="This stack config deploys EC2 instances with config stacks"
    --8<-- "docs/examples/cloud_vm/complete/aws-complete.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml title="The same stack config can be configured to quite an extent"
    --8<-- "docs/examples/cloud_vm/complete/aws-complete-advanced.yaml"
    ```

- Whereas sample mlops stack for deployment on Cloud PaaS looks as follows:

===+ "Simple Deployment Configuration"
    ```yaml title="This stack config deploys an EKS cluster with LakeFS"
    --8<-- "docs/examples/kubernetes/lakefs/aws-lakefs.yaml"
    ```
=== "Advanced Deployment Configuration"
    ```yaml title="The same stack config can be configured to quite an extent"
    --8<-- "docs/examples/kubernetes/lakefs/aws-lakefs-advanced.yaml"
    ```

- Terraform plan from this configuration can be inspected using the `mlinfra` cli command:
```
mlinfra terraform --action=plan --stack-config-path=aws-lakefs-k8s.yaml
```

- The mlops stacks configuration can be deployed using the `mlinfra` cli command:
```
mlinfra terraform --action=apply --stack-config-path=aws-lakefs-k8s.yaml
```
