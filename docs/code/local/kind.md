`kind` deploys MLOps `stack` on top of [kind cluster](https://kind.sigs.k8s.io/) on your machine. Please ensure that docker is installed and running on your machine, along with the latest version of kind.

# Kind Deployment in Local Environment 🖥️

This directory contains YAML configurations for deploying applications using **Kind** (Kubernetes IN Docker). Kind allows you to run Kubernetes clusters in Docker containers, making it an excellent tool for local development and testing.

## 📂 Files Included

- **`kind.yaml`**: Basic configuration for deploying an application using Kind.
- **`kind-advanced.yaml`**: Advanced configuration with optimizations and additional features for a more robust Kind deployment.

## ⚙️ Prerequisites

Before you begin, ensure you have the following:

- **Docker**: Installed and running on your machine.
- **Kind**: Installed. You can install Kind by following the instructions on the [Kind installation page](https://kind.sigs.k8s.io/docs/user/quick-start/#installation).
- **kubectl**: Installed to interact with your Kind cluster.

## 🚀 Deployment Instructions

### 1. Create a Kind Cluster

To create a Kind cluster using the basic configuration, run the following command:

```bash
kind create cluster --config kind.yaml
```

For an advanced setup, use:

```bash
kind create cluster --config kind-advanced.yaml
```

### 2. Verifying Your Cluster

To check the status of your Kind cluster, run:

```bash
kubectl cluster-info
```

You should see details about the Kubernetes cluster and its components.

### 3. Deploying Applications

Once the cluster is up and running, you can deploy your applications using `kubectl`. For example, to apply a deployment configuration file:

```bash
kubectl apply -f <your-deployment-file>.yaml
```

### 4. Accessing Your Application

If you need to access your application, you can use port forwarding:

```bash
kubectl port-forward svc/<your-service-name> 8080:80
```

Replace `<your-service-name>` with the name of your service. Access your application at `http://localhost:8080`.

## 🔧 Customization Tips

- **Cluster Configuration**: Modify the YAML files to adjust resource allocations, networking, or add additional features as needed.
- **Docker Resources**: Ensure your Docker daemon has enough resources (CPU, memory) allocated to handle the Kind cluster.

## 🧹 Cleanup

To delete your Kind cluster when you are finished, run:

```bash
kind delete cluster
```

## 📄 Additional Resources

- [Kind Documentation](https://kind.sigs.k8s.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)