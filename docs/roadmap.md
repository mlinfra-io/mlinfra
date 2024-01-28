`platinfra` comes with the promise of deployment of MLOps stacks across all popular and available cloud providers. For each cloud provider, `platinfra` aims to cover the following deployments (if ofcourse the deployment type is supported by the cloud provider):

- Infrastructure-as-a-Service ( [IaaS](https://aws.amazon.com/what-is/iaas/) )
- Platform-as-a-Service ( [PaaS](https://aws.amazon.com/types-of-cloud-computing/) )

Software-as-a-Service ( [SaaS](https://aws.amazon.com/saas/) ) deployments were not considered in initial planning, but if anyone has more experience in SaaS IaC, and is interested in supporting this, get in touch!

!!! note "Did i miss your favourite deployment environment?"

    If yes, then please open a Feature Request, write down your ideas and i'll get in touch with you!

## Deployment Environments

As already mentioned, `platinfra` is currently under active development. There is a two way relationship between cloud and mlops tools with deployments which can be depicted via: MLOps-Tools :material-arrow-left-right: Deployment Type :material-arrow-left-right: Cloud Providers

We use the following statuses to denote the availability of deployments across Cloud providers and MLOps toolings.

| Status                    | Meaning                                       |
| :-----------:             | :-----------------:                           |
| :material-close:          | No deployment type is available yet           |
| :material-check:          | IaaS deployment is available                  |
| :material-check-outline:  | PaaS deployment is available                  |
| :material-check-all:      | Both, IaaS and PaaS deployments are available |


=== "Cloud"

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

=== "Local"
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


### Stack Name

#### Orchestrators

- [ ] Kubeflow

### Stack Name

- [ ] Add support for Seldon
