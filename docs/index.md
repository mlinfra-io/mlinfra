## What is platinfra?

`platinfra` is a python package designed to streamline the deployment of various MLOps tools within a MLOps stack, quickly and with best practices. The core philosophy behind `platInfra` is to simplify and expedite the deployment of MLOps infrastructure. This approach enables _ML Engineers_ or _ML Platform engineers_ to concentrate on delivering business value, by significantly reducing the time and resources typically required for deploying MLOps tools on the cloud.

## Why platinfra?

`platInfra` was conceived from a personal challenge I faced while deploying various MLOps tools in cloud environments. The absence of a standardized method for deploying MLOps tools and infrastructure on the cloud was not only noticeable but also a source of frustration. As my discussions with industry peers expanded, it became evident that knowledge regarding the deployment of ML Infrastructure is fragmented across various tool-specific documentation sources. This fragmentation hinders rapid and best practice-compliant deployment of diverse MLOps tools within a stack, posing challenges for platform teams who aim to:

- Experiment with different tools in MLOps stacks to customize solutions according to their specific needs.
- Swiftly evaluate new tools without delving into extensive deployment documentation.
- Deploy tools within the MLOps stack efficiently and in accordance with best practices, thereby circumventing the need for prolonged development cycles and complex planning.

The fundamental concept behind `platInfra` is to establish a universal Infrastructure as Code (IaC) framework that expedites the creation and deployment of MLOps stacks. This package empowers _MLOps Engineers_ and _Platform Engineers_ to deploy a variety of MLOps tools across different stages of the machine learning lifecycle. The essence of PlatInfra lies in its Python layer, which interprets the deployment configuration and utilizes Terraform modules to deploy these tools. It further enhances the process by dynamically generating a suite of inputs, roles, and permissions, thereby simplifying and streamlining the deployment process.

## How does it work?
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

The above configuration can be deployed using the following command:

```bash
platinfra terraform --action=apply --stack-config-path=aws-mlops-stack.yaml
```
