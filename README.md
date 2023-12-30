# platinfra

> _One tool to deploy all them platforms_

- My intention behind this work is to liberate IaC logic for creating MLOps stacks which is usually tied to other frameworks.

- All you need is terraform to run this project and `let it rip!`

## Vision

- I realised MLOps infrastructure deployment is not as easy and common over the years of creating and deploying ML platforms for multiple teams. A lot of the times, teams start on wrong foot, leading to months of planning and implementation of MLOps infrastructure. This project is an attempt to create a common MLOps infrastructure deployment framework that can be used by any ML team to deploy their MLOps stack in a single command.

- The idea is that for anyone willing to deploy MLOps infrastructure, they should be able to do so by providing basic minimum configuration and just running a single command.

## Supported Providers

This project will be supporting the following providers:

- [AWS](https://aws.amazon.com/)
- [GCP](https://cloud.google.com/)
- [Azure](https://azure.microsoft.com/en-us)
- [Kubernetes](https://kubernetes.io/)
- [DigitalOcean](https://www.digitalocean.com/)
- Bare metal (such as [Hetzner](https://www.hetzner.com/de))
- [Openstack](https://www.openstack.org/)
- [docker compose](https://docs.docker.com/compose/)

## Deployment Config

- `platinfra` deploys infrastructure using a declarative approach

- The minimal spec for aws cloud as infra with custom applications deployed is as follows:

```yaml
name: aws-mlops-stack
provider:
  name: aws
  account-id: xxxxxxxxx
  deployment_component: cloud-infra # (this would create ec2 instances and then deploy applications on it)
stack:
  data_versioning:
    - dvc # can also be pachyderm or lakefs or neptune and so on
  secrets_manager:
    - secrets_manager # can also be vault or any other
  experiment_tracker:
    - mlflow # can be weights and biases or determined, or neptune or clearml and so on...
  pipelining:
    - zenml # can also be argo, or luigi, or airflow, or dagster, or prefect or flyte or kubeflow and so on...
  orchestrator:
    - aws-batch # can also be aws step functions or aws-fargate or aws-eks or azure-aks and so on...
  runtime_engine:
    - ray # can also be horovod or apache spark
  artifact_tracker:
    - mlflow # can also be neptune or clearml or lakefs or pachyderm or determined or wandb and so on...
  # model registry and serving are quite close, need to think about them...
  model_registry:
    - bentoml # can also be  mlflow or neptune or determined and so on...
  model_serving:
    - nvidia triton # can also be bentoml or fastapi or cog or ray or seldoncore or tf serving
  monitoring:
    - nannyML # can be grafana or alibi or evidently or neptune or mlflow or prometheus or weaveworks and so on...
  alerting:
    - mlflow # can be mlflow or neptune or determined or weaveworks or prometheus or grafana and so on...
```

- Other stacks such as feature_store, event streamers, loggers or [cost dashboards](https://www.nebuly.com/) can be added via community requests.

## Development

- This project relies on terraform for IaC code and python to glue it all together.
- To get started, install terraform and python. You can install the required python packages by running `pip3 install -r requirements.txt`
- You can run any of the available examples from the `examples` folder using `invoke terraform --stack-config-path examples/<application>/<cloud>-<application>.yaml --action <action>` where `<action>` corresponds to terraform actions such as `plan`, `apply`, `destroy` and `output`.
- You can also run `python3 -m platinfra.main --help` to see all the available options.

For more information, please refer to the [Engineering wiki](https://platinfra.github.io/) of the project regarding what are the different components of the project and how they work together.

## Contributions

- Contributions are welcome! Help us onboard all of the available mlops tools on currently available cloud providers.
- For major changes, please open an issue first to discuss what you would like to change. A team member will get to you soon.
