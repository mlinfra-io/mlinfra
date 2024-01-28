###

### Deploying a Stack

- A sample mlops stack looks like this the following scripts.

=== "Simple Deployment Configuration"
    !!! info "This stack config deploys an EKS cluster with LakeFS"
    ```yaml
    --8<-- "docs/examples/kubernetes/lakefs/aws-lakefs.yaml"
    ```
=== "Advanced Deployment Configuration"
    !!! info "The same stack config can be configured to quite an extent"
    ```yaml
    --8<-- "docs/examples/kubernetes/lakefs/aws-lakefs-advanced.yaml"
    ```

- Terraform plan from this configuration can be inspected using the `platinfra` cli command:
```
platinfra terraform --action=plan --stack-config-path=aws-lakefs-k8s.yaml
```

- The mlops stacks configuration can be deployed using the `platinfra` cli command:
```
platinfra terraform --action=apply --stack-config-path=aws-lakefs-k8s.yaml
```
