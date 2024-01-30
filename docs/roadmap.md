`mlinfra` comes with the promise of deployment of MLOps stacks across all popular and available cloud providers. For each cloud provider, `mlinfra` aims to cover the following deployments (if ofcourse the deployment type is supported by the cloud provider):

- Infrastructure-as-a-Service ( [IaaS](https://aws.amazon.com/what-is/iaas/) )
- Platform-as-a-Service ( [PaaS](https://aws.amazon.com/types-of-cloud-computing/) )


## Deployment Environments

As already mentioned, `mlinfra` is currently under active development. There is a two way relationship between cloud and mlops tools with deployments which can be depicted via: MLOps-Tools :material-arrow-left-right: Deployment Type :material-arrow-left-right: Cloud Providers

We use the following statuses to denote the availability of deployments across Cloud providers and MLOps toolings.

| Status                    | Meaning                                       |
| :-----------:             | :-----------------:                           |
| :material-close:          | No deployment type is available yet           |
| :material-check:          | IaaS deployment is available                  |
| :material-check-outline:  | PaaS deployment is available                  |
| :material-check-all:      | Both, IaaS and PaaS deployments are available |

#### Cloud Platforms

| Cloud                                                 | Deployment Type Available |
| :-----------:                                         | :-----------------:       |
| [AWS](https://aws.amazon.com/)                        | :material-check-all:      |
| [GCP](https://cloud.google.com/)                      | :material-close:          |
| [Azure](https://azure.microsoft.com/en-us)            | :material-close:          |
| [Digital Ocean Cloud](https://www.digitalocean.com/)  | :material-close:          |
| [IBM Cloud](https://www.ibm.com/cloud)                | :material-close:          |
| [Alibaba Cloud](https://eu.alibabacloud.com/en)       | :material-close:          |
| [Oracle Cloud](https://www.oracle.com/cloud/)         | :material-close:          |
| [Hetzner Cloud](https://www.hetzner.com/cloud/)       | :material-close:          |


#### Local
!!! note "Local deployment is only possible on local k8s platforms"

| Local                             | Deployment Type Available |
| :-----------:                     | :-----------------:       |
| [K3S](https://k3s.io/)            | :material-close:          |
| [kind](https://kind.sigs.k8s.io/) | :material-close:          |

## MLOps Stacks


#### Data Versioning

=== "Cloud"

    | Tool                          | AWS                  | GCP                 | Azure               | Digital Ocean Cloud  | IBM Cloud            | Alibaba Cloud        | Oracle Cloud         | Hetzner Cloud        |
    | :-----------:                 | :-----------------:  | :-----------------: | :-----------------: | :-----------------:  | :-----------------:  | :-----------------:  | :-----------------:  | :-----------------:  |
    | [lakefs](https://lakefs.io/)  | :material-check-all: | :material-close:    | :material-close:    | :material-close:     | :material-close:     | :material-close:     | :material-close:     | :material-close:     |

=== "Local"

    | Tool                          | k3s                 | kind                |
    | :-----------:                 | :-----------------: | :-----------------: |
    | [lakefs](https://lakefs.io/)  | :material-close:    | :material-close:    |


The details on the rest of the roadmap would be shared soon!g
