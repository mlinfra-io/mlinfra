The config file is made with simplicity in mind. It is comprised of 4 distinct sections which allow both simplicity and maximum room for configurability of the underlying cloud infrastructure as well as the mlops stack tooling being deployed using `platinfra`. The 4 different components are as follows:

### name

- The `name` denotes the name used to refer the stack. It is used internally to track the state of the the stack deployment.
- It is also used as the [bucket_prefix](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#bucket_prefix) of the terraform state bucket which is used to store the state for this stack.
- The `name` of the config must not exceed 37 characters otherwise an error would be thrown at the `platinfra terraform --action=apply` time.

### provider

### deployment

### stack
