# 🐳 Kubernetes Examples

Welcome to the **Kubernetes** examples! This section provides configurations and guides to help you deploy scalable MLOps stacks on Kubernetes clusters. Kubernetes is ideal for managing containerized applications, and these examples will help you harness its power for your machine learning workflows.

## 🚀 Getting Started

### Prerequisites
Before deploying the examples, make sure you have:
- **Kubernetes Cluster**: A running Kubernetes cluster (minikube, EKS, GKE, or AKS).
- **kubectl**: Command-line tool to interact with your Kubernetes cluster. [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- **Helm**: Package manager for Kubernetes. [Install Helm](https://helm.sh/docs/intro/install/)
- **Terraform**: Version `>= 1.8.0` installed. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### 📦 Installation

1. **Set Up Kubernetes Cluster**:
    - If you don’t have a cluster, create one using your preferred platform. For example, using **minikube**:
      ```bash
      minikube start
      ```

2. **Install `mlinfra`**:
    ```bash
    pip install mlinfra
    ```

3. **Choose an Example**:
    Navigate to the example directory of your choice:
    ```bash
    cd examples/kubernetes/lakefs
    ```

4. **Deploy to Kubernetes**:
    Use `mlinfra` to deploy the chosen configuration:
    ```bash
    mlinfra terraform --action apply --stack-config-path ./config/k8s-config.yaml
    ```

## 📂 Available Examples

| Example File            | Description |
| ------------------------| ----------- |
| `aws-lakefs.yaml`       | Basic configuration for deploying LakeFS on Kubernetes |
| `aws-lakefs-advanced.yaml` | Advanced configuration for LakeFS with additional cloud database storage options |

### ℹ️ Note:
- Ensure your **VPC** has a **NAT Gateway** configured so that the node groups can access the EKS cluster. [Configure a NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- You can choose between creating a **single NAT gateway** or **one NAT gateway per Availability Zone (AZ)**.

## 🌟 Why Use Kubernetes?
Using Kubernetes brings several benefits:
- **Scalability**: Automatically scale containers based on load and resource utilization.
- **Portability**: Deploy your MLOps stack across multiple cloud providers or on-premise.
- **Resilience**: Kubernetes ensures your services remain available by self-healing when issues occur.

## 🆘 Need Assistance?
For help, open an issue or join our [Discord community](#) for support and to share your feedback.