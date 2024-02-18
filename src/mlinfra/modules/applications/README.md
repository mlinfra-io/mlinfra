# Application Modules

## Rules for adding an application module

- Define a cloud_vm and kubernetes module
- Define a `yaml` declarative file for the application module
- Set the following fields for the inputs:

```yaml
- name: vpc_id
  user_facing: false
  description: VPC id
  value: module.vpc.vpc_id
  default: None
```

- For non-user facing modules, add the terraform module reference in the `value` key and leave the default as none.
- For user facing inputs, add the key `user_facing: true` with a default value.
- Define outputs with the following fields:

```yaml
- name: mlflow_server_address
  description: MLFlow server address. Right now its composed of EC2 instance IP address, with http scheme.
  export: true
```

- Set `export: true` if you need to see the export in the final outputs.
