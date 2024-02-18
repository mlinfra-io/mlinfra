The deployment section is designed to enable configuration of the deployment type, either IaaS or PaaS, within your chosen cloud provider. This section is highly adaptable, requiring only one mandatory field: `type`. The `type` field accepts one of two values:

- [IaaS](https://aws.amazon.com/what-is/iaas/): Specified as `cloud_vm`.
- [PaaS](https://aws.amazon.com/types-of-cloud-computing/): Specified as `kubernetes`.

Additionally, the `config` subsection under `deployment` offers detailed, fine-grained configuration options for the respective cloud resources. These options vary based on the deployment type:

For `cloud_vm`, the configuration is limited to `vpc`.
For `kubernetes`, configurations extend to `vpc`, `kubernetes`, and `node_groups`.

A sample `deployment` block can look as follows:
=== "Simple Deployment Configuration"
    ```yaml title="Minimal kubernetes type deployment"
    --8<-- "docs/examples/kubernetes/lakefs/aws-lakefs.yaml:6:7"
    ```
=== "Advanced Deployment Configuration"
    ```yaml title="Advanced kubernetes type deployment with user configured vpc and k8s cluster"
    --8<-- "docs/examples/kubernetes/lakefs/aws-lakefs-advanced.yaml:6:26"
    ```


Further elaboration on these configurations can be found in the Cloud Config section.
