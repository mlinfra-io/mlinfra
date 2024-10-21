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

To install the `platinfra` package, you can use pip. It's recommended to create a Python virtual environment first:

```bash
python -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
pip install platinfra
```

## 🌐 Deployment Instructions

### 1. Basic LakeFS Setup

The `aws-lakefs.yaml` file provides a straightforward setup for deploying LakeFS. This is suitable for initial testing and smaller workloads.

**To deploy:** 

```bash
platinfra terraform --action apply --stack-config-path aws-lakefs.yaml
```

This command will create the necessary AWS resources and deploy LakeFS.

### 2. Advanced LakeFS Setup

The `aws-lakefs-advanced.yaml` file contains a more comprehensive configuration, including features like:

- Enhanced scaling options
- Custom resource requests and limits
- Integrations with additional AWS services

**To deploy:** 

```bash
platinfra terraform --action apply --stack-config-path aws-lakefs-advanced.yaml
```

Feel free to modify the advanced configuration according to your specific use cases and resource requirements.

## 🔧 Customization Tips

- **IAM Roles**: Ensure that the necessary IAM roles and policies are in place to allow LakeFS to access required AWS resources, such as S3.
- **Environment Variables**: Adjust environment variables in the YAML files for configuring LakeFS settings.
- **Storage Configuration**: Make sure to configure persistent storage options if needed.

## 📦 Managing Your Deployment

- **Update Configuration**: To apply changes, use:
  ```bash
  platinfra terraform --action apply --stack-config-path <your-updated-file>.yaml
  ```
- **Check Status**: Monitor the deployment using:
  ```bash
  aws cloudformation describe-stacks --stack-name lakefs-stack
  ```
- **Logs**: View logs for troubleshooting in the AWS Console.

## 🧹 Cleanup

To remove the LakeFS deployment, execute:

```bash
platinfra terraform --action destroy --stack-config-path aws-lakefs.yaml
platinfra terraform --action destroy --stack-config-path aws-lakefs-advanced.yaml
```

## 📞 Support & Resources

For additional support, consider the following resources:

- [LakeFS Documentation](https://docs.lakefs.io/)
- [AWS Documentation](https://aws.amazon.com/documentation/)
