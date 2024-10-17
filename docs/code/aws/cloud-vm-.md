# ☁️ Cloud Infrastructure Examples

Welcome to the **Cloud Infrastructure** examples! This section contains ready-to-use configurations to help you deploy scalable MLOps stacks on cloud platforms like AWS. Each example is designed to showcase a different tool or workflow, making it easier for you to find and deploy the infrastructure that fits your needs.

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
    cd examples/cloud_infra/dagster
    ```

4. **Configure AWS Credentials**:
    Modify the `terraform.tfvars` file to update your AWS account details. Make sure your AWS credentials are correctly configured.

5. **Deploy**:
    Use `mlinfra` to apply the configuration:
    ```bash
    mlinfra terraform --action apply --stack-config-path ./config/aws-config.yaml
    ```

## 📂 Examples Available

| Example Folder | Description |
| -------------- | ----------- |
| `dagster`      | Deploy **Dagster** for orchestrating your ML pipelines on AWS |
| `mlflow`       | Set up **MLflow** for experiment tracking and model management |
| `wandb`        | Configure **Weights & Biases** for experiment tracking on cloud |
| `lakefs`       | Create a **LakeFS** setup for versioning your datasets in the cloud |
| `prefect`      | Set up **Prefect** for orchestrating cloud-based ML workflows |

## 🌟 Why Use Cloud Infrastructure?
Deploying your MLOps stack on the cloud brings several advantages:
- **Scalability**: Easily scale resources up or down based on workload.
- **Cost Efficiency**: Pay for what you use, and reduce costs with managed services.
- **Flexibility**: Leverage powerful cloud services to enhance your ML workflows.

## 🆘 Need Help?
Feel free to open an issue or join our [Discord community](#) for discussions, troubleshooting, or contributing new ideas.
