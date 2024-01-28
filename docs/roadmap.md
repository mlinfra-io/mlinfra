`platinfra` comes with the promise of deployment of MLOps stacks across all popular and available cloud providers and their internal infrastructure. For each cloud provider, `platinfra` aims to cover the following these available [cloud computing services](https://aws.amazon.com/types-of-cloud-computing/) for all given cloud providers (if ofcourse supported by cloud providers):

- Infrastructure-as-a-Service ( [IaaS](https://aws.amazon.com/what-is/iaas/) )
- Platform-as-a-Service ( [PaaS](https://aws.amazon.com/types-of-cloud-computing/) )

Software-as-a-Service ( [SaaS](https://aws.amazon.com/saas/) ) deployments were not considered in initial planning, but if anyone has more experience in SaaS IaC, and is interested in supporting this, get in touch!

!!! note "Did i miss your favourite deployment environment?"
        If yes, then please open a Feature Request, write down your ideas and i'll get in touch with you!

## Deployment Environments

#### Local

- [ ] k3s
- [ ] kind

#### Cloud

- [ ] AWS cloud
    - [x] deployment on EC2
    - [x] deployment on EKS
- [ ] Azure cloud
- [ ] GCP cloud
- [ ] Digital Ocean cloud
- [ ] IBM Cloud
- [ ] Alibaba Cloud
- [ ] Oracle Cloud
- [ ] Hetzner Cloud


## MLOps Stacks

This section highlights the stack tools which would be supported on the deployment environments along with their status. A single check (:material-check:) indicates that only IaaS support is available, an outlined check (:material-check-outline:) indicates that only PaaS support is available and

| Status                    | Meaning                                       |
| :-----------:             | :-----------------:                           |
| :material-close:          | No deployment type is available yet           |
| :material-check:          | IaaS deployment is available                  |
| :material-check-outline:  | PaaS deployment is available                  |
| :material-check-all:      | Both, IaaS and PaaS deployments are available |



#### Data Versioning

=== "Cloud"

    | Tool                          | AWS                       | Azure                 | GCP                   | AWS                   |
    | :-----------:                 | :-----------------:       | :-----------------:   | :-----------------:   | :-----------------:   |
    | [lakefs](https://lakefs.io/)  | :material-check-all:      | :material-close:      | :material-close:      | :material-close:      |

=== "Local"

    | Tool                          | k3s                       | kind                      |
    | :-----------:                 | :-----------------:       | :-----------------:       |
    | [lakefs](https://lakefs.io/)  | :material-check-all:      | :material-check-all:      |


### Stack Name

#### Orchestrators

- [ ] Kubeflow

### Stack Name

- [ ] Add support for Seldon
