# Deploying Prefect on AWS ☁️

This guide provides instructions for deploying Prefect on Amazon Web Services (AWS) using the provided YAML configuration files.

## Overview 📊

Prefect is a modern workflow orchestration tool designed to enable efficient data pipeline management. This deployment will help you run Prefect on AWS, providing scalability and reliability for your workflows.

## Requirements ✔️

Before you start, ensure you have the following:
- **Terraform**: Version **>= 1.4.0** installed on your machine.
- **AWS Account**: A valid AWS account with necessary permissions to create resources.

## Installation ⚙️

1. **Create a Python Virtual Environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate
   ```

2. **Install the Required Python Package:**
   ```bash
   pip install platinfra
   ```

## Deployment Configuration 📄

In the `prefect` folder, you have the following configuration files:

1. **aws-prefect.yaml**: Basic configuration for deploying Prefect on AWS.
2. **aws-prefect-advanced.yaml**: Advanced configuration with additional settings and optimizations.

### Configuration File Details

- **aws-prefect.yaml**: This file sets up a simple Prefect server instance on AWS with default settings.
  
- **aws-prefect-advanced.yaml**: This file includes advanced features, such as a larger instance type, additional storage options, and monitoring configurations for enhanced performance.

## Running the Deployment 🚀

To deploy Prefect on AWS, follow these steps:

1. **Copy the Configuration File:**
   Choose one of the configuration files (basic or advanced) and modify it with your AWS account details and desired configurations.

2. **Deploy the Configuration:**
   Run the following command to apply the configuration:
   ```bash
   platinfra terraform --action apply --stack-config-path <path-to-your-config-file>
   ```
   Replace `<path-to-your-config-file>` with the path to either `aws-prefect.yaml` or `aws-prefect-advanced.yaml`.

## Conclusion 🎉

Congratulations! You have successfully deployed Prefect on AWS. You can now start orchestrating your workflows in the cloud. For further configurations and integrations, refer to the Prefect documentation.