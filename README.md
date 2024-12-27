![MLInfra Github Banner](https://github.com/mlinfra-io/mlinfra/blob/main/docs/_images/mlinfra-banner-wide.png)

<div align="center">
  <h3>
    Open source MLOps infrastructure deployment on Public Cloud providers
  </h3>
  <div>
    <strong>Open source MLOps:</strong> Open source tools for different stages in an MLOps lifecycle.
  </div>
  <div>
    <strong>Public Cloud Providers:</strong> Supporting all major cloud providers including AWS, GCP, Azure and Oracle Cloud
  </div>
  </br>
  <div>
    <img alt="GitHub License" src="https://img.shields.io/github/license/mlinfra-io/mlinfra?color=orange">
    <a href="https://github.com/mlinfra-io/mlinfra/releases"><img src="https://img.shields.io/github/v/release/mlinfra-io/mlinfra?include_prereleases&color=orange" alt="mlinfra releases"></a>
    <a href="https://mlinfra.io/development/"><img src="https://img.shields.io/badge/docs-latest-orange" alt="Documentation"></a>
    <a href="https://github.com/mlinfra-io/mlinfra/actions/workflows/on_pr.yml?query=branch:main"><img src="https://img.shields.io/github/actions/workflow/status/mlinfra-io/mlinfra/on_pr.yml?&label=All%20tests&color=orange" alt="CI test status"></a>
    <a href="https://pypi.org/project/mlinfra/"><img src="https://img.shields.io/pypi/v/mlinfra.svg?label=pypi+mlinfra&color=orange" alt="mlinfra Python package on PyPi"></a>
    <img src="https://img.shields.io/pypi/dm/mlinfra?color=orange" alt="mlinfra Python package downloads on PyPi">
    <a href="https://discord.gg/8eYWVvEYmR"><img src="https://img.shields.io/discord/1199078513463009321?logo=Discord&logoColor=white&label=Discord&color=%23434EE4" alt="Discord"></a>
    <img src="https://img.shields.io/badge/Cloud%20Providers-orange" alt="cloud providers"/>
    <a href="https://mlinfra.io/latest/code/aws/cloud_vm/"><img src="https://github.com/mlinfra-io/mlinfra/blob/main/docs/_images/aws_icon.svg" height="20" alt="AWS Examples"/></a>
    <img src="https://github.com/mlinfra-io/mlinfra/blob/main/docs/_images/gcp_icon.svg" height="20" alt="GCP Examples"/>
    <img src="https://github.com/mlinfra-io/mlinfra/blob/main/docs/_images/azure_icon.svg" height="20" alt="Azure Examples"/>
    <img src="https://github.com/mlinfra-io/mlinfra/blob/main/docs/_images/alibaba_icon.svg" height="20" alt="Alibaba Examples"/>
  </div>
</div>
</br>

`mlinfra` is the swiss army knife for deploying MLOps tooling anywhere. It aims to make MLOps infrastructure deployment easy and accessible to all ML teams by liberating IaC logic for creating MLOps stacks which is usually tied to other frameworks.

Contribute to the project by opening a issue or joining project roadmap and design related discussion on [discord](https://discord.gg/8eYWVvEYmR). Complete roadmap will be released soon!

## 🚀 Installation

### Requirements
`mlinfra` requires the following to run perfectly:

- `terraform` >= `1.10.2` should be installed on the system.

`mlinfra` can be installed simply by creating a python virtual environment and installing `mlinfra` pip package
```bash
python -m venv .venv
source .venv/bin/activate
pip install mlinfra
```

Copy a deployment config from the [examples](https://github.com/mlinfra-io/mlinfra/tree/4d21aa465fa8d40aabcf9877f3f99c4ede687459/examples) folder, change your AWS account in the config file, configure your AWS credentials and deploy the configuration using

```bash
mlinfra terraform apply --config-file <path-to-your-config>
```

For more information, read the [mlinfra user guide](https://mlinfra.io/user_guide/)

## Deployment Config

`mlinfra` deploys infrastructure using declarative approach. It requires resources to be defined in a `yaml` file with the following format

```yaml
name: aws-mlops-stack
provider:
  name: aws
  account-id: xxxxxxxxx
  region: eu-central-1
deployment:
  type: cloud_vm # (this would create ec2 instances and then deploy applications on it)
stack:
  data_versioning:
    - lakefs # can also be pachyderm or lakefs or neptune and so on
  experiment_tracker:
    - mlflow # can be weights and biases or determined, or neptune or clearml and so on...
  orchestrator:
    - zenml # can also be argo, or luigi, or airflow, or dagster, or prefect or flyte or kubeflow or ray and so on...
  model_inference:
    - bentoml # can also be ray or KF serving or seldoncore or tf serving
  monitoring:
    - nannyML # can be grafana or alibi or evidently or neptune or prometheus or weaveworks and so on...
  alerting:
    - mlflow # can be mlflow or neptune or determined or weaveworks or prometheus or grafana and so on...
```

- For examples, check out the [documentation](https://mlinfra.io/latest/code/local/kind/).

- _*NOTE*_: This was minimal spec for aws cloud as infra with custom applications. Other stacks such as feature_store, event streamers, loggers or [cost dashboards](https://www.kubecost.com/) can be added via community requests. For more information, please [check out the docs](https://mlinfra.io/).

## Supported Providers

The core purpose is to build for all cloud and deployment platforms out there. Any user should be able to just change the cloud provider or runtime environment (whether it be linux or windows) and have the capability to deploy the same tools.

mlinfra will be supporting the following providers:

#### Local machine (for development)
  - [x] [kind](https://kind.sigs.k8s.io/)
  - [x] [minikube](https://minikube.sigs.k8s.io/)
  - [ ] [k3s](https://k3s.io/)
  - [ ] [docker compose](https://docs.docker.com/compose/)
  - [ ] [k0s](https://k0sproject.io/) (for a more hybrid approach)

#### Cloud Providers (for deployment and production ready)
- [x] [AWS](https://aws.amazon.com/)
- [ ] [GCP](https://cloud.google.com/)
- [ ] [Azure](https://azure.microsoft.com/en-us)
- [ ] [AliBaba](https://www.alibabacloud.com/)
- [ ] [Openstack](https://www.openstack.org/)
- [ ] [Oracle Cloud](https://www.oracle.com/cloud/)
- [ ] Bare metal (such as [Hetzner](https://www.hetzner.com/de) or [DigitalOcean](https://www.digitalocean.com/))

## Supported deployment types

When deploying on managed cloud providers, users can deploy their infrastructure on top of either:
- `Virtual Machines` such as [EC2](https://aws.amazon.com/ec2/) on AWS Cloud, [Google Virtual machine](https://cloud.google.com/compute/docs/instances) instances on GCP Cloud and [Azure Virtual Machine](https://azure.microsoft.com/en-us/products/virtual-machines) on Azure Cloud.
- or [Kubernetes](https://kubernetes.io/) such as [EKS](https://aws.amazon.com/eks/) on AWS Cloud, [GKE](https://cloud.google.com/kubernetes-engine) on GCP Cloud and [AKS](https://azure.microsoft.com/en-us/products/kubernetes-service) on Azure Cloud.


## Supported MLOps Tools

`mlinfra` intends to support as many [MLOps tools](https://github.com/EthicalML/awesome-production-machine-learning/) deployable in a platform in their standalone as well as high availability across different layers of an MLOps stack:
- `data_ingestion`
- `data_versioning`
- `data_processing`
- `vector_database`
- `experiment_tracker`
- `orchestrator`
- `model_inference`
- `monitoring`
- `alerting`

## Development

- This project relies on terraform for IaC code and python to glue it all together.
- To get started, install terraform and python.
- You can install the required python packages by running `uv sync`
- You can run any of the available examples from the `examples/` folder by running the following command in root directory `python src/mlinfra/cli/cli.py terraform <action> --config-file examples/<deployment-type>/<file>.yaml` where `<action>` corresponds to terraform actions such as `plan`, `apply` and `destroy`.

For more information, please refer to the Engineering Wiki of the project (https://mlinfra.io/user_guide/) regarding what are the different components of the project and how they work together.

## Contributions

- Contributions are welcome! Help us onboard all of the available mlops tools on currently available cloud providers.
- For major changes, please open [an issue](https://github.com/mlinfra-io/mlinfra/issues) first to discuss what you would like to change. A team member will get to you soon.
- For information on the general development workflow, see the [contribution guide](CONTRIBUTING.md).


## License

The `mlinfra` library is distributed under the [Apache-2 license](https://github.com/mlinfra-io/mlinfra/blob/main/LICENSE).
