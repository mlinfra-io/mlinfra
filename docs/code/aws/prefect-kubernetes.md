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
