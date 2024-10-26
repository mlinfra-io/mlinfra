# ☁️ Cloud VM Examples

Welcome to the **Cloud VM** examples! This section contains ready-to-use configurations to help you deploy scalable MLOps stacks on cloud platforms like AWS. Each example is designed to showcase a different tool or workflow, making it easier for you to find and deploy the infrastructure that fits your needs.

## 🚀 Getting Started

### Prerequisites
Before you begin, ensure you have the following:
- **Terraform**: Version `>= 1.8.0` installed on your system. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS Account**: Make sure your AWS account is set up and you have appropriate IAM roles.
- **AWS CLI**: Ensure your AWS CLI is configured with the correct credentials. [Configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- **Python**: Version `>= 3.7` to run the setup scripts.

### 📦 Installation
1. **Create a Virtual Environment**:
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows use: venv\Scripts\activate
    ```
2. **Install `mlinfra`**:
    ```bash
    pip install mlinfra
    ```

3. **Choose an Example**:
    Navigate to the example you want to deploy:
    ```bash
    cd examples/cloud_vm/dagster
    ```

4. **Configure AWS Credentials**:
    Modify the YAML configuration file (e.g., `aws-dagster.yaml`) to update your AWS account details. Ensure your AWS credentials are correctly configured.

5. **Deploy**:
    Use `mlinfra` to apply the configuration:
    ```bash
    mlinfra terraform --action apply --stack-config-path examples/cloud_vm/dagster/aws-dagster.yaml
    ```

## 📂 Examples Available

| Example Folder | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| `complete`     | Complete setups for ML projects in the cloud                |
| `lakefs`       | Create a **LakeFS** setup for versioning your datasets in the cloud |
| `mlflow`       | Set up **MLflow** for experiment tracking and model management |
| `wandb`        | Configure **Weights & Biases** for experiment tracking on cloud |
| `prefect`      | Set up **Prefect** for orchestrating cloud-based ML workflows |
| `dagster`      | Deploy **Dagster** for orchestrating your ML pipelines on AWS |


## 🌟 Why Use Cloud Infrastructure?
Deploying your MLOps stack on the cloud brings several advantages:
- **Scalability**: Easily scale resources up or down based on workload.
- **Cost Efficiency**: Pay for what you use, and reduce costs with managed services.
- **Flexibility**: Leverage powerful cloud services to enhance your ML workflows.

## 🆘 Need Help?
Feel free to open an issue or join our [Discord community](#) for discussions, troubleshooting, or contributing new ideas.


## Complete example with all stacks

# AWS Complete Deployment 🌐

This directory contains YAML configurations for setting up a complete infrastructure on AWS. These files are designed to facilitate the deployment of cloud resources, with options for both basic and advanced configurations.

## Directory Structure

- `aws-complete.yaml`: Basic configuration file for deploying essential cloud infrastructure on AWS.
- `aws-complete-advanced.yaml`: Advanced configuration file that includes enhanced features for scalability, security, and performance optimization.

## Deployment Instructions

### 1. Prerequisites

Before you begin, make sure you have:

- An AWS account with the necessary permissions to create and manage resources.
- AWS CLI installed and configured with your credentials.
- `cloudformation` permissions to deploy AWS infrastructure.

### 2. Basic Deployment

To deploy the basic infrastructure, use the following command:

```bash
aws cloudformation deploy --template-file aws-complete.yaml --stack-name aws-mlops-stack-complete
```

### 3. Advanced Deployment

For a more comprehensive setup with additional features, execute:

```bash
mlinfra terraform --action apply --stack-config-path examples/cloud_vm/complete/aws-complete-advanced.yaml
```

### 4. Verifying Deployment

To verify that your infrastructure has been set up correctly, check the status of your CloudFormation stack:

```bash
aws cloudformation describe-stacks --stack-name aws-mlops-stack-complete
```

Or for the advanced setup:

```bash
aws cloudformation describe-stacks --stack-name aws-mlops-stack-complete-advanced
```

### 5. Managing Resources

You can manage and monitor your deployed resources through the AWS Management Console. Use the CloudFormation section to view your stacks, events, and outputs for further details.

## Additional Resources

- [AWS CloudFormation Documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

## License 📄

This project is licensed under the Apache-2 License.


## data_versioning

#### lakefs

# 🌊 AWS LakeFS Configuration

This directory contains configuration files for deploying LakeFS on AWS. LakeFS is an open-source data version control system designed for object storage, enabling you to manage and version your data efficiently.

## 📁 Files Included

- **`aws-lakefs.yaml`**: Basic configuration for deploying LakeFS on AWS.
- **`aws-lakefs-advanced.yaml`**: Advanced configuration for deploying LakeFS with additional features and custom settings.

## 🚀 Getting Started

To use these configurations, ensure you have the following prerequisites:

- An active AWS account.
- AWS Command Line Interface (CLI) installed and configured.
- Necessary IAM permissions for creating resources.
- Python 3.x installed.

### 📦 Installation

To install the `mlinfra` package, you can use pip. It's recommended to create a Python virtual environment first:

```bash
python -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
pip install mlinfra
```

## 🌐 Deployment Instructions

### 1. Basic LakeFS Setup

The `aws-lakefs.yaml` file provides a straightforward setup for deploying LakeFS. This is suitable for initial testing and smaller workloads.

**To deploy:** 

```bash
mlinfra terraform --action apply --stack-config-path examples/cloud_vm/lakefs/aws-lakefs.yaml
```

This command will create the necessary AWS resources and deploy LakeFS.

### 2. Advanced LakeFS Setup

The `aws-lakefs-advanced.yaml` file contains a more comprehensive configuration, including features like:

- Enhanced scaling options
- Custom resource requests and limits
- Integrations with additional AWS services

**To deploy:** 

```bash
mlinfra terraform --action apply --stack-config-path examples/cloud_vm/lakefs/aws-lakefs-advanced.yaml
```

## 🔧 Customization Tips

- **IAM Roles**: Ensure that the necessary IAM roles and policies are in place to allow LakeFS to access required AWS resources, such as S3.
- **Environment Variables**: Adjust environment variables in the YAML files for configuring LakeFS settings.
- **Storage Configuration**: Configure persistent storage options as needed.

## 📦 Managing Your Deployment

- **Update Configuration**: To apply changes, use:
  ```bash
  mlinfra terraform --action apply --stack-config-path <your-updated-file>.yaml
  ```
- **Check Status**: Monitor the deployment status using:
  ```bash
  aws cloudformation describe-stacks --stack-name aws-mlops-stack-lakefs
  ```
- **Logs**: View logs for troubleshooting in the AWS Console.

## 🧹 Cleanup

To remove the LakeFS deployment, execute:

```bash
mlinfra terraform --action destroy --stack-config-path aws-lakefs.yaml
mlinfra terraform --action destroy --stack-config-path aws-lakefs-advanced.yaml
```

## 📞 Support & Resources

For additional support, consider the following resources:

- [LakeFS Documentation](https://docs.lakefs.io/)
- [AWS Documentation](https://aws.amazon.com/documentation/)


## experiment_tracking

#### mlflow

# MLflow on AWS Deployment 🚀

This README provides guidance on deploying MLflow on AWS using the provided configuration files in the `mlflow` folder.

## Overview

MLflow is an open-source platform to manage the ML lifecycle, including experimentation, reproducibility, and deployment. This setup allows you to deploy MLflow on AWS easily.

## Requirements

Before you start, ensure you have the following:

- An AWS account with the necessary permissions to create and manage resources.
- Terraform installed on your system (version >= 1.4.0).

## Installation

1. **Create a Python Virtual Environment:**

   ```bash
   python -m venv venv
   source venv/bin/activate
   ```

2. **Install the Required Packages:** 
   ```bash
   pip install mlinfra
   ```

## Deployment Configuration

You can choose between two deployment configurations based on your needs:

### 1. Basic MLflow Deployment

- **File:** `aws-mlflow.yaml`

This configuration is suitable for a simple MLflow deployment with essential features. To deploy:

```bash
mlinfra terraform --action apply --stack-config-path examples/cloud_vm/mlflow/aws-mlflow.yaml
```

### 2. Advanced MLflow Deployment

- **File:** `aws-mlflow-advanced.yaml`

This configuration includes additional features for a more robust MLflow deployment. To deploy:

```bash
mlinfra terraform --action apply --stack-config-path examples/cloud_vm/mlflow/aws-mlflow-advanced.yaml
```

## Configuration

- Update the `aws-mlflow.yaml` or `aws-mlflow-advanced.yaml` files with your AWS account details and any other custom configurations you require.
- Ensure your AWS credentials are properly configured on your machine.

## Additional Information

For more details on using MLflow and its capabilities, refer to the [MLflow Documentation](https://www.mlflow.org/docs/latest/index.html).

## Contribution

Feel free to contribute to this project! If you have suggestions or improvements, open an issue or pull request.

## License

This project is licensed under the Apache-2.0 License.


#### wandb

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

To install the `mlinfra` package, you can use pip. It's recommended to create a Python virtual environment first:

```bash
python -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
pip install mlinfra
```

### 2. Basic Deployment

To deploy using the basic configuration, run:

```bash
mlinfra terraform --action apply --stack-config-path examples/cloud_vm/wandb/aws-wandb.yaml
```

### 3. Advanced Deployment

For an advanced setup with additional features, execute:

```bash
mlinfra terraform --action apply --stack-config-path examples/cloud_vm/wandb/aws-wandb-advanced.yaml
```

### 4. Verifying Deployment

After applying the configurations, check the status of the Weights and Biases services:

```bash
aws cloudformation describe-stacks --stack-name aws-mlops-stack-mlflow
```

### 5. Accessing Weights and Biases UI

You can access the Weights and Biases UI to monitor your machine learning experiments. Depending on your service configuration, you may need to set up an appropriate networking method, such as an Elastic Load Balancer (ELB) or an ingress point.

Once set up, visit the ELB URL or the endpoint you configured to access the Weights and Biases UI.

## Additional Resources

- [Weights and Biases Documentation](https://docs.wandb.ai/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

## License 📄

This project is licensed under the Apache-2 License.


## orchestrator

#### prefect

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
   pip install mlinfra
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
   mlinfra terraform --action apply --stack-config-path examples/cloud_vm/prefect/aws-prefect-advanced.yaml
   ```
   

## Conclusion 🎉

Congratulations! You have successfully deployed Prefect on AWS. You can now start orchestrating your workflows in the cloud. For further configurations and integrations, refer to the Prefect documentation.

#### dagster

# 🚀 Dagster on AWS Cloud Setup

Welcome to the **Dagster AWS Cloud Setup** documentation! This guide will help you deploy Dagster on AWS using the provided configurations for a seamless data orchestration experience. Let's get started! 🛠️

## 📂 Configuration Files Overview

### 1. `aws-dagster.yaml`
This file provides a **basic setup** for deploying Dagster on AWS. It includes essential configurations to quickly get you up and running with Dagster. Use this file if you are just starting out or need a straightforward deployment.

**Features:**
- 🏗️ Basic infrastructure setup
- 🧩 Core components of Dagster
- 🔌 Integration with AWS services like S3 and CloudWatch

### 2. `aws-dagster-advanced.yaml`
This file offers a **more advanced setup** for deploying Dagster on AWS, with additional configurations for better scalability, security, and performance. Use this file if you need more control and features for your deployment.

**Features:**
- 📈 Enhanced scalability and performance configurations
- 🔒 Advanced security settings
- 🔄 Custom integrations and multi-environment support

## 📦 Prerequisites

Before deploying Dagster on AWS, make sure you have:
1. 🏷️ AWS Account with appropriate permissions.
2. 🏗️ [AWS CLI](https://aws.amazon.com/cli/) installed and configured.
3. 🧩 [Dagster](https://dagster.io/) installed on your local machine.
4. 🔧 Proper IAM roles and security groups set up.

## 🚀 Deployment Instructions

### Basic Setup (`aws-dagster.yaml`)
1. **Configure your AWS CLI:**
    ```bash
    aws configure
    ```
2. **Deploy the infrastructure:**
    ```bash
    aws cloudformation deploy --template-file aws-dagster.yaml --stack-name aws-mlops-stack-dagster
    ```
3. 🎉 **You're all set!** Access Dagster via the provided endpoint.

### Advanced Setup (`aws-dagster-advanced.yaml`)
1. **Configure your AWS CLI:**
    ```bash
    aws configure
    ```
2. **Deploy the infrastructure:**
    ```bash
    aws cloudformation deploy --template-file aws-dagster-advanced.yaml --stack-name aws-mlops-stack-dagster
    ```
3. **Customize the parameters if needed:**
    Modify the `.yaml` file to suit your specific needs, including scaling options, security settings, and more.
4. 🎉 **Enjoy your advanced setup!**

## 📝 Notes
- Ensure the **VPC settings** and **subnets** are correctly configured to avoid deployment issues.
- For the advanced setup, you might need to adjust **IAM roles** and **network configurations**.

## 📚 Additional Resources
- 📖 [Dagster Documentation](https://docs.dagster.io/)
- 📖 [AWS CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)

Feel free to customize the `.yaml` files to suit your specific requirements. 🛠️ Happy deploying!