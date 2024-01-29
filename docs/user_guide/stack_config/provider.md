The `provider` block is designed to configure the cloud provider for deploying the stack configuration. To facilitate user convenience in cross-cloud deployment, the `provider` logic has been distinctly separated from the `deployment` logic. This approach ensures that a user can deploy the same stack on a different cloud provider by simply modifying the provider section.


#### AWS

A sample AWS `provider` config looks as follows:
```yaml title="Sample Provider Configuration for AWS"
--8<-- "docs/examples/kubernetes/lakefs/aws-lakefs.yaml:2:5"
```
The following is the description of fields in provider:

- `name`: name of the cloud provider
- `account_id`: this refers to the account id of your AWS account
- `region`: The region of deployment for AWS

!!! warning
    All above fields of the cloud provider are mandatory and cannot be left blank.


!!! info
    Currently only AWS is the supported provider. `provider` sections for different clouds would be updated as soon as there's a new provider available.
