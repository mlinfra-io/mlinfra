The config file is made with simplicity in mind. It is comprised of 4 distinct sections which allow both simplicity and maximum room for configurability of the underlying cloud infrastructure as well as the mlops stack tooling being deployed using `mlinfra`. The 4 different components are as follows:


<figure markdown>
  ![Image title](../../_images/stack-components-light.png#only-light){loading=lazy }
  ![Image title](../../_images/stack-components-dark.png#only-dark){loading=lazy }
  <figcaption>A sample stack file configuration</figcaption>
</figure>

!!! info Types of the components of stack file
    Only the `name` is a `string` property in the stack file whereas `provider`, `deployment` and `stack` are all objects.

### name

- The `name` denotes the name used to refer the stack. It is used internally to track the state of the the stack deployment.
- It is also used as the [bucket_prefix](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#bucket_prefix) of the terraform state bucket which is used to store the state for this stack.

!!! info

    The `name` of the config must not exceed _37 characters_ otherwise an error would be thrown at the `mlinfra terraform --action=apply` time.

### [provider](provider.md)

- The `provider` block determines where the deployment of the stack config is going to take place.
- This block also configures cloud provider's information, such as in case of AWS, account id and region of deployment.

- For more details, see the provider page.

### [deployment](deployment.md)

- The `deployment` block configures the type of deployment (whether IaaS or PaaS) on the cloud provider and provides a space for adding any further configurations to the underlying cloud components.
- The `deployment.type` can be set to `cloud_vm` for IaaS or `kubernetes` for PaaS deployments.
- The `deployment.config` can be used to further configure the cloud components; such as the `vpc` or `kubernetes` cluster for more user defined customisations.

- For more details, see the deployment page.

### [stack](stack.md)
