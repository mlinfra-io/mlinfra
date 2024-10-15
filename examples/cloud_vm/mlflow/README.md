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
   pip install platinfra
   ```

## Deployment Configuration

You can choose between two deployment configurations based on your needs:

### 1. Basic MLflow Deployment

- **File:** `aws-mlflow.yaml`

This configuration is suitable for a simple MLflow deployment with essential features. To deploy:

```bash
platinfra terraform --action apply --stack-config-path <path-to-your-config>/aws-mlflow.yaml
```

### 2. Advanced MLflow Deployment

- **File:** `aws-mlflow-advanced.yaml`

This configuration includes additional features for a more robust MLflow deployment. To deploy:

```bash
platinfra terraform --action apply --stack-config-path <path-to-your-config>/aws-mlflow-advanced.yaml
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
