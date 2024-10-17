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
