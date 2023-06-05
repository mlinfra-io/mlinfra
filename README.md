# ultimate-mlops-stacks

- My intention behind this work is to liberate IaC logic for creating MLOps stacks which is usually tied to other frameworks.

- All you need is terraform to run this project and `let it rip!`

## Vision

I realised MLOps infrastructure deployment is not as easy and common over the years of creating and deploying ML platforms for multiple teams. A lot of the times, teams start on wrong foot, leading to months of planning and implementation of MLOps infrastructure.

This project is an attempt to create a common MLOps infrastructure deployment framework that can be used by any ML team to deploy their MLOps stack in a single command.

The idea is that for anyone willing to deploy MLOps infrastructure, they should be able to do so by providing basic minimum configuration and just running a single command.

## Supported Providers

This project will be supporting the following providers:

- aws
- gcp
- azure
- kubernetes # (for cloud agnostic deployment)
- digital ocean
- bare metal (such as hetzner)
- openstack
- docker-compose

## Spec for MLOps stack

- The idea is to give users the ability to deploy infrastructure; native to cloud, cloud based or cloud agnostic with minimal effort.
- The minimal spec for the aws cloud native mlops stack is as follows:

```yaml
name: aws-mlops-stack
provider:
  name: aws
  account-id: xxxxxxxxx
  deployment_component: cloud-native # (this would create aws native mlops applications)
stack:
  data_versioning:
    - s3
  secrets_manager:
    - aws_secrets_manager
  experiment_tracker:
    - sagemaker
  pipelining:
    - sagemaker_pipelines
  orchestrator:
    - sagemaker_pipelines # can also be aws step functions
  artifact_tracker:
    - s3
  model_registry:
    - sagemaker_model_registry
  model_serving:
    - sagemaker_model_inference
  monitoring:
    - sagemaker_model_monitor
  alerting:
    - sagemaker_model_monitor
```

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

- Following is the example for a native kubernetes stack. Note that the only thing that changes is the deployment component from aws to kubernetes everything else remains the same, as the applications are now being installed as helm charts.

```yaml
name: kubernetes-mlops-stack
provider:
  name: aws
  account-id: xxxxxxxxx
  deployment_component: kubernetes # (this would create eks and then deploy applications via helm chart on it)
stack:
  data_versioning:
    - dvc # can also be pachyderm or lakefs or neptune and so on
  secrets_manager:
    - secrets_manager # can also be vault or any other
  experiment_tracker:
    - mlflow # can be weights and biases or determined, or neptune or clearml and so on...
  pipelining:
    - zenml # can also be argo, or luigi, or airflow, or dagster, or prefect or flyte or kubeflow and so on...
  # orchestrator:
  #   - aws-batch # can also be aws step functions or aws-fargate or aws-eks or azure-aks and so on...
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
