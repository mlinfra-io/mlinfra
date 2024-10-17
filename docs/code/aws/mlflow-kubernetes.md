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