`minikube` deploys MLOps `stack` on top of [minikube cluster](https://minikube.sigs.k8s.io/) on your machine. Please ensure that docker is installed and running on your machine, along with the latest version of minikube.

# Minikube Deployment in Local Environment 🚀

This directory contains YAML configurations for deploying applications using **Minikube**. Minikube is a tool that enables you to run Kubernetes clusters locally, making it an excellent choice for development and testing.

## 📂 Files Included

- **`minikube.yaml`**: Basic configuration for deploying an application using Minikube.
- **`minikube-advanced.yaml`**: Advanced configuration with optimizations and additional features for a more robust Minikube deployment.

## ⚙️ Prerequisites

Before you begin, ensure you have the following:

- **Docker**: Installed and running on your machine (as Minikube can use Docker as a driver).
- **Minikube**: Installed. You can install Minikube by following the instructions on the [Minikube installation page](https://minikube.sigs.k8s.io/docs/start/).
- **kubectl**: Installed to interact with your Minikube cluster.

## 🚀 Deployment Instructions

### 1. Start Minikube

To start a Minikube cluster using the basic configuration, run the following command:

```bash
minikube start --config minikube.yaml
```

For an advanced setup, use:

```bash
minikube start --config minikube-advanced.yaml
```

### 2. Verifying Your Cluster

To check the status of your Minikube cluster, run:

```bash
minikube status
```

You should see details about the Minikube cluster and its components.

### 3. Deploying Applications

Once the cluster is up and running, you can deploy your applications using `kubectl`. For example, to apply a deployment configuration file:

```bash
kubectl apply -f <your-deployment-file>.yaml
```

### 4. Accessing Your Application

To access your application, you can use:

```bash
minikube service <your-service-name>
```

Replace `<your-service-name>` with the name of your service. This command will open your default web browser and direct you to your application.

## 🔧 Customization Tips

- **Cluster Configuration**: Modify the YAML files to adjust resource allocations, networking, or add additional features as needed.
- **Minikube Configurations**: You can adjust Minikube settings such as the driver or resources using:

```bash
minikube config set <property> <value>
```

## 🧹 Cleanup

To delete your Minikube cluster when you are finished, run:

```bash
minikube delete
```

## 📄 Additional Resources

- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

Once the stacks have been deployed, there is one last step that allows the deployed stacks to be accessed on your local machine. You need to open a new terminal window and find the minikube profile that you're using `minikube profile list` and run `minikube tunnel --profile='<minikube-profile>'` to allow the services to be accessible on the local instance.
