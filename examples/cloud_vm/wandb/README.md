# Weights and Biases Deployment on AWS 🌊

This directory contains YAML configurations for deploying Weights and Biases (Wand) on AWS. Weights and Biases is a powerful tool designed for managing and monitoring machine learning experiments, helping teams to track metrics and visualize results effectively.

## Directory Structure

- **`aws-wand.yaml`**: This file contains the basic configuration for deploying Weights and Biases on AWS.
- **`aws-wand-advanced.yaml`**: This file includes advanced configurations for a more robust Weights and Biases deployment, incorporating features for scalability and performance.

## Deployment Instructions

### 1. Prerequisites

Before deploying, ensure you have the following:

- An active AWS account with the necessary permissions.
- AWS CLI configured with your credentials.
- Python 3.x installed.

### 📦 Installation

To install the `platinfra` package, you can use pip. It's recommended to create a Python virtual environment first:

```bash
python -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
pip install platinfra
```

### 2. Basic Deployment

To deploy using the basic configuration, run:

```bash
platinfra terraform --action apply --stack-config-path aws-wand.yaml
```

### 3. Advanced Deployment

For an advanced setup with additional features, execute:

```bash
platinfra terraform --action apply --stack-config-path aws-wand-advanced.yaml
```

### 4. Verifying Deployment

After applying the configurations, check the status of the Weights and Biases services:

```bash
aws cloudformation describe-stacks --stack-name wand-stack
```

### 5. Accessing Weights and Biases UI

You can access the Weights and Biases UI to monitor your machine learning experiments. Depending on your service configuration, you may need to set up an appropriate networking method, such as an Elastic Load Balancer (ELB) or an ingress point.

Once set up, visit the ELB URL or the endpoint you configured to access the Weights and Biases UI.

## Additional Resources

- [Weights and Biases Documentation](https://docs.wandb.ai/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

## License 📄

This project is licensed under the Apache-2 License.
