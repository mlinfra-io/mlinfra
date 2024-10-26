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
    - For cloud-based deployment, create a cluster using your preferred platform (e.g., EKS, GKE, AKS).
    - For local development, you can use Minikube:
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
    mlinfra terraform --action apply --stack-config-path examples/kubernetes/lakefs/aws-lakefs.yaml
  ```

## 📂 Available Examples

| Example File            | Description                                                   |
| ----------------------- | ------------------------------------------------------------- |
| `Complete`              | Comprehensive configuration for deploying ML projects on Kubernetes.       |
| `LakeFS`                | Configuration for deploying LakeFS on Kubernetes.                  |
| `MLflow`                | Configuration for deploying MLflow on Kubernetes.                      |
| `Prefect`               | Configuration for deploying Prefect on Kubernetes.                      |



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

#### Complete

# Complete Deployment on Kubernetes 🚀

This directory contains YAML configurations for deploying a complete solution on a Kubernetes cluster. These configurations are designed to help you set up an entire application stack using Kubernetes.

## 📂 Files Included

- **`aws-complete.yaml`**: Basic configuration for deploying a complete solution on a Kubernetes cluster.
- **`aws-complete-advanced.yaml`**: Advanced configuration for deploying a complete solution with additional features and optimizations.

## ⚙️ Prerequisites

Before starting, ensure you have:

- An existing Kubernetes cluster (e.g., Amazon EKS, GKE, AKS, or any self-managed cluster).
- `kubectl` installed and configured to connect to your Kubernetes cluster.
- Necessary permissions for creating resources in the Kubernetes cluster.
- Docker images for your application available, or use existing images.

## 📦 Deployment Instructions

### 1. Basic Complete Deployment

To deploy the complete solution using the basic setup, run:

```bash
kubectl apply -f aws-complete.yaml
```

This configuration is suitable for basic usage and testing.

### 2. Advanced Complete Deployment

For a more robust deployment that includes optimizations and additional features, use the advanced configuration:

```bash
kubectl apply -f aws-complete-advanced.yaml
```

This file allows for customizations such as:

- **Increased resource requests/limits for better performance**
- **Integration with external services**
- **Enhanced monitoring and logging features**

### 3. Verifying Your Deployment

To check the status of your deployments, use:

```bash
kubectl get pods
```

You can also check the services to see if they are running correctly:

```bash
kubectl get svc
```

### 4. Accessing the Application

Once deployed, you can access your application via the service endpoints. If the services are not exposed externally, you may need to set up port forwarding:

```bash
kubectl port-forward svc/<your-service-name> 8080:80
```

Replace `<your-service-name>` with the name of your service. Visit `http://localhost:8080` to access your application.

## 🔧 Customization Tips

- **Scaling**: Modify replica counts in the YAML files to adjust the number of instances running.
- **Resource Allocation**: Tweak resource requests and limits based on application needs.
- **Environment Variables**: Set any required environment variables directly in the YAML files.

## 🧹 Cleanup

To delete your complete deployment:

```bash
kubectl delete -f aws-complete.yaml
kubectl delete -f aws-complete-advanced.yaml
```

## 📄 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS Documentation](https://aws.amazon.com/documentation/)

#### lakefs

# 🌊 Deploying LakeFS on Kubernetes

This directory contains YAML configurations for deploying LakeFS on a Kubernetes cluster. LakeFS is an open-source data version control system designed for managing and versioning data in object storage, enabling efficient data workflows.

## 📁 Files Included

- **`lakefs.yaml`**: Basic configuration for deploying LakeFS on Kubernetes.
- **`lakefs-advanced.yaml`**: Advanced configuration for deploying LakeFS with additional features and custom settings.

## 🚀 Getting Started

To deploy LakeFS on a Kubernetes cluster, ensure you have the following prerequisites:

- An active Kubernetes cluster (e.g., using EKS, GKE, AKS).
- `kubectl` installed and configured to interact with your cluster.
- Necessary permissions to create resources in the cluster.

## 🌐 Deployment Instructions

### 1. Basic LakeFS Setup

The `lakefs.yaml` file provides a straightforward setup for deploying LakeFS. This configuration is suitable for initial testing and smaller workloads.

**To deploy:** 

```bash
kubectl apply -f lakefs.yaml
```

This command will create the necessary Kubernetes resources and deploy LakeFS in your cluster.

### 2. Advanced LakeFS Setup

The `lakefs-advanced.yaml` file contains a more comprehensive configuration, which may include:

- Enhanced scaling options
- Custom resource requests and limits
- Integrations with additional services (e.g., S3, RDS)

**To deploy:** 

```bash
kubectl apply -f lakefs-advanced.yaml
```

Feel free to modify the advanced configuration according to your specific use cases and resource requirements.

## 🔧 Customization Tips

- **Storage Configuration**: Ensure you configure persistent storage for LakeFS to manage data effectively.
- **Environment Variables**: Adjust any environment variables in the YAML files for configuring LakeFS settings.
- **Service Configuration**: Modify service settings if you need to expose LakeFS externally or set up an ingress controller.

## 📦 Managing Your Deployment

- **Update Configuration**: To apply changes, use:
  ```bash
  kubectl apply -f <your-updated-file>.yaml
  ```
- **Check Status**: Monitor the deployment using:
  ```bash
  kubectl get pods
  ```
- **Logs**: View logs for troubleshooting:
  ```bash
  kubectl logs <pod-name>
  ```

## 🧹 Cleanup

To remove the LakeFS deployment, execute:

```bash
kubectl delete -f lakefs.yaml
kubectl delete -f lakefs-advanced.yaml
```

## 📞 Support & Resources

For additional support, consider the following resources:

- [LakeFS Documentation](https://docs.lakefs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

## License 📄

This project is licensed under the Apache-2 License.


#### mlflow

===+ "Simple Deployment Configuration"
# MLflow Deployment on AWS 🚀

This directory contains configuration files for deploying [MLflow](https://mlflow.org/), an open-source platform for managing the end-to-end machine learning lifecycle, on AWS infrastructure.

## Directory Structure

- `aws-mlflow.yaml`: Basic setup for deploying MLflow on AWS.
- `aws-mlflow-advanced.yaml`: Advanced setup with additional configurations for enhanced performance and scalability on AWS.

## Prerequisites

Before deploying MLflow on AWS, ensure you have:

- An AWS account with sufficient permissions to create resources (e.g., EC2, S3, RDS).
- AWS CLI installed and configured (`aws configure`).
- `kubectl` installed and set up to interact with your Kubernetes cluster on AWS (e.g., EKS).
- Optional: Docker installed locally if you plan to build custom MLflow images.

## Deployment Instructions

### 1. Set Up AWS Resources

Ensure that the following AWS resources are set up:

- **S3 Bucket**: For storing MLflow artifacts. Create a bucket or use an existing one.
- **RDS (Optional)**: For storing MLflow experiment metadata. Alternatively, use a local or other supported database.
- **IAM Role**: Make sure your EC2 or EKS nodes have the necessary IAM roles to access S3, RDS, and any other AWS services you plan to use.

### 2. Basic MLflow Deployment on AWS

Use the `aws-mlflow.yaml` file for a straightforward MLflow deployment on AWS.

1. Update the `aws-mlflow.yaml` file to include your S3 bucket information and any environment variables.
2. Apply the deployment using `kubectl`:

    ```bash
    kubectl apply -f aws-mlflow.yaml
    ```

This will create an MLflow server, using S3 as the artifact store and a local backend for experiment metadata (or any database you configure).

### 3. Advanced MLflow Deployment on AWS

For more advanced deployment, use `aws-mlflow-advanced.yaml`. This setup may include features like:

- Autoscaling for the MLflow server.
- Enhanced resource allocation for performance.
- Integration with managed databases (e.g., RDS).
- Custom Docker images.

1. Update the `aws-mlflow-advanced.yaml` file as needed:
    - Specify environment variables, including database connection strings.
    - Adjust resource requests and limits.
    - Configure autoscaling if required.
2. Apply the deployment:

    ```bash
    kubectl apply -f aws-mlflow-advanced.yaml
    ```

### 4. Configure Access to MLflow

- **NodePort**: Use NodePort in your YAML files to expose the MLflow server on a specific port.
- **LoadBalancer**: Expose the MLflow server using a LoadBalancer service for easier access from outside the cluster.
- **Ingress**: For more control over routing and domain configuration, use an Ingress controller.

After deployment, check the status:

```bash
kubectl get pods
kubectl get services
```

### 5. Customize MLflow Configuration

You can modify environment variables in the YAML files to adjust the following:

- **Backend Store**: Specify a database connection (e.g., MySQL, PostgreSQL, or AWS RDS) for experiment tracking.
- **Artifact Store**: Use S3 by configuring the `MLFLOW_S3_ENDPOINT_URL` and `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` if needed.
- **Environment Variables**: Configure authentication and other settings as per your requirements.

### 6. Monitoring and Logging

To view the logs of the MLflow server:

```bash
kubectl logs <mlflow-pod-name>
```

For real-time monitoring, consider integrating with AWS CloudWatch.

## Additional Resources

- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

## License 📄

This project is licensed under the Apache-2 License.

#### Prefect (Server & Worker)

# Prefect Deployment on Kubernetes 🚀

This directory contains YAML configurations for deploying Prefect on a Kubernetes cluster. Prefect is a workflow orchestration tool that allows you to schedule, monitor, and manage data pipelines with ease.

## 📂 Files Included

- **`aws-prefect.yaml`**: Basic configuration for deploying Prefect on a Kubernetes cluster.
- **`aws-prefect-advanced.yaml`**: Advanced configuration for deploying Prefect with additional customizations and features.

## ⚙️ Prerequisites

Before starting, ensure you have:

- An existing Kubernetes cluster (e.g., Amazon EKS, GKE, AKS, or any self-managed cluster).
- `kubectl` installed and configured to connect to your Kubernetes cluster.
- Necessary permissions for creating resources in the Kubernetes cluster.
- Docker images for Prefect available, or use the official Prefect images.

## 📦 Deployment Instructions

### 1. Basic Prefect Deployment

The `aws-prefect.yaml` file provides a straightforward setup for deploying Prefect. This configuration is ideal for small to medium workloads.

To deploy Prefect using the basic setup:

```bash
kubectl apply -f aws-prefect.yaml
```

### 2. Advanced Prefect Deployment

For a more robust deployment with enhanced features like resource allocation, autoscaling, or custom environment variables, use the `aws-prefect-advanced.yaml`:

```bash
kubectl apply -f aws-prefect-advanced.yaml
```

This file can be modified to include specific customizations such as:

- **Increased resource requests/limits for scalability**
- **Integration with external monitoring or logging systems**
- **Custom environment variables and secrets management**

### 3. Verifying Your Deployment

To check if your Prefect pods are running correctly, use:

```bash
kubectl get pods
```

You can also describe the Prefect services to get more information:

```bash
kubectl get svc
```

### 4. Accessing the Prefect UI

Once Prefect is deployed, you can access the Prefect UI for monitoring workflows. You may need to set up port forwarding if the service is not exposed externally:

```bash
kubectl port-forward svc/prefect-service 8080:80
```

Visit `http://localhost:8080` to access the Prefect UI.

## 🔧 Customization Tips

- **Scaling**: Modify replica counts in the YAML files to scale Prefect components as needed.
- **Resource Allocation**: Adjust resource requests and limits for memory and CPU based on workload requirements.
- **Secrets**: Configure any necessary secrets for external services directly in Kubernetes or using a tool like `kubectl` or `helm`.

## 🧹 Cleanup

To delete your Prefect deployment:

```bash
kubectl delete -f aws-prefect.yaml
kubectl delete -f aws-prefect-advanced.yaml
```

## 📄 Additional Resources

- [Prefect Documentation](https://docs.prefect.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)