![Banner Logo](docs/_images/mlinfra-banner-wide.png)

[![](https://img.shields.io/pypi/v/mlinfra)](https://pypi.org/project/mlinfra)
![GitHub License](https://img.shields.io/github/license/mlinfra-tools/mlinfra?color=orange)
[![docs](https://img.shields.io/badge/docs-latest-orange)](https://mlinfra.io/)
![PyPI - Downloads](https://img.shields.io/pypi/dm/mlinfra?color=orange)
![Discord](https://img.shields.io/discord/1199078513463009321?color=orange)


> _One tool to deploy all them mlops tools_

`mlinfra` is the swiss army knife for deploying scalable MLOps infrastructure. It aims to make MLOps infrastructure deployment easy and accessible to all ML teams by liberating IaC logic for creating MLOps stacks which is usually tied to other frameworks.

Contribute to the project by opening a issue or joining project roadmap and design related discussion on [discord](https://discord.gg/8eYWVvEYmR). Complete roadmap will be released soon!

## 🚀 Installation

### Requirements
`mlinfra` requires the following to run perfectly:

- `terraform` >= `1.4.0` should be installed on the system.

`mlinfra` can be installed simply by creating a python virtual environment and installing `mlinfra` pip package
```bash
python -m venv venv
source venv/bin/activate
pip install mlinfra
```

Copy a deployment config from the [examples](https://github.com/mlinfra-tools/mlinfra/tree/4d21aa465fa8d40aabcf9877f3f99c4ede687459/examples) folder, change your AWS account in the config file, configure your AWS credentials and deploy the configuration using

```bash
mlinfra terraform --action apply --stack-config-path <path-to-your-config>
```

For more information, read the [mlinfra user guide](https://mlinfra.io/user_guide/)

## Supported Providers

The core purpose is to build for all cloud and deployment platforms out there. Any user should be able to just change the cloud provider or runtime environment (whether it be linux or windows) and have the capability to deploy the same tools.

Currently a lot of work has been done around AWS

This project will be supporting the following providers:
- [x] [AWS](https://aws.amazon.com/)
- [ ] [GCP](https://cloud.google.com/)
- [ ] [Azure](https://azure.microsoft.com/en-us)
- [ ] [Kubernetes](https://kubernetes.io/)
  - [x] [EKS](https://aws.amazon.com/eks/)
  - [ ] [GKE](https://cloud.google.com/kubernetes-engine)
  - [ ] [AKS](https://azure.microsoft.com/en-us/products/kubernetes-service)
- [ ] [DigitalOcean](https://www.digitalocean.com/)
- [ ] Bare metal (such as [Hetzner](https://www.hetzner.com/de))
- [ ] [Openstack](https://www.openstack.org/)
- [ ] [docker compose](https://docs.docker.com/compose/)
- [ ] [k3s](https://k3s.io/)
- [ ] [kind](https://kind.sigs.k8s.io/)

## Supported MLOps Tools

`mlinfra` intends to support as many [MLOps tools](https://github.com/EthicalML/awesome-production-machine-learning/) deployable in a platform in their standalone as well as high availability across different layers of an MLOps stack:
- data_versioning
- experiment_tracker
- orchestrator
- artifact_tracker / model_registry
- model_inference
- monitoring
- alerting

## Deployment Config

- `mlinfra` deploys infrastructure using declarative approach. It requires resources to be defined in a `yaml` file with the following format

```yaml
name: aws-mlops-stack
provider:
  name: aws
  account-id: xxxxxxxxx
  region: eu-central-1
deployment:
  type: cloud_infra # (this would create ec2 instances and then deploy applications on it)
stack:
  data_versioning:
    - lakefs # can also be pachyderm or lakefs or neptune and so on
  secrets_manager:
    - secrets_manager # can also be vault or any other
  experiment_tracker:
    - mlflow # can be weights and biases or determined, or neptune or clearml and so on...
  orchestrator:
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

- This was minimal spec for aws cloud as infra with custom applications. Other stacks such as feature_store, event streamers, loggers or [cost dashboards](https://www.kubecost.com/) can be added via community requests.
- For more information, please [check out the docs](https://mlinfra.io/) for detailed documentation.

## Vision

- I realised MLOps infrastructure deployment is not as easy and common over the years of creating and deploying ML platforms for multiple teams. A lot of the times, teams start on wrong foot, leading to months of planning and implementation of MLOps infrastructure. This project is an attempt to create a common MLOps infrastructure deployment framework that can be used by any ML team to deploy their MLOps stack in a single command.

## Development

- This project relies on terraform for IaC code and python to glue it all together.
- To get started, install terraform and python.
- You can install the required python packages by running `pip install -r requirements-dev.txt`
- You can run any of the available examples from the `examples` folder by running `cd src` and `invoke terraform --stack-config-path examples/<application>/<cloud>-<application>.yaml --action <action>` where `<action>` corresponds to terraform actions such as `plan`, `apply` and `destroy`.

For more information, please refer to the Engineering Wiki of the project (https://mlinfra.io/user_guide/) regarding what are the different components of the project and how they work together.

## Contributions

- Contributions are welcome! Help us onboard all of the available mlops tools on currently available cloud providers.
- For major changes, please open [an issue](https://github.com/mlinfra-tools/mlinfra/issues) first to discuss what you would like to change. A team member will get to you soon.
- For information on the general development workflow, see the [contribution guide](CONTRIBUTING.md).


## License

The `mlinfra` library is distributed under the [Apache-2 license](https://github.com/mlinfra-tools/mlinfra/blob/main/LICENSE).
