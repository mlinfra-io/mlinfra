# Welcome to platinfra

`platinfra` came to be when i started exploring the different tools in mlops space and had the intention of deploying them on the cloud. The idea was to liberate the IaC logic for creating MLOps stacks and accelerate the deployment and decision making process for MLOps engineers so that they can focus where it matters; on choosing the right tooling for their workflows.

platinfra allows MLOps and DevOps to deploy different MLOps tools for different stages of the machine learning lifecycle. The magic of platinfra is hidden in the python layer, that reads through the deployment config and deploys all these tools using terraform modules and connects them using dynamically generated set of roles and permissions.

platinfra deploys infrastructure using a declarative approach. The minimal spec for aws cloud as infra with custom applications deployed is as follows:

```yaml
name: aws-mlops-stack
provider:
  name: aws
  account-id: xxxxxxxxx
deployment:
  type: kubernetes
stack:
  data_versioning:
    - dvc # can also be pachyderm or lakefs or neptune and so on
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
    - nvidia_triton # can also be bentoml or fastapi or cog or ray or seldoncore or tf serving
  monitoring:
    - nannyML # can be grafana or alibi or evidently or neptune or mlflow or prometheus or weaveworks and so on...
  alerting:
    - mlflow # can be mlflow or neptune or determined or weaveworks or prometheus or grafana and so on...
```
