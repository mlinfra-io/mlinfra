`provider` block configures the cloud provider to deploy the stack config. The `provider` logic has been isolated away from the `deployment` logic keeping user's feasibility of cross-cloud-deployment in mind. A user should be able to use the same config and deploy the entire stack at another cloud provider by just changing the `provider` section and keeping the rest of the stack config same.

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
