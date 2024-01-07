import json
import os
import shutil
import subprocess

from .constants import TF_PATH


def clean_tf_directory():
    if os.path.isdir(TF_PATH):
        shutil.rmtree(TF_PATH)


def generate_tf_json(module_name: str, json_module: json):
    with open(f"./{TF_PATH}/{module_name}.tf.json", "w", encoding="utf-8") as tf_json:
        json.dump(json_module, tf_json, ensure_ascii=False, indent=2)


def check_terraform_version():
    try:
        # Run 'terraform version' command in the shell
        result = subprocess.run(
            ["terraform", "version"], capture_output=True, text=True, check=True
        )

        # Extract the version information from the output
        output_lines = result.stdout.split("\n")
        for line in output_lines:
            if line.startswith("Terraform"):
                version_info = line.split()[1]
                print(f"Terraform is installed. Version: {version_info}")

    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        print("Terraform is not installed or an error occurred.")
        print("Please install Terraform and try again.")
        exit(1)


def terraform_tested_version():
    # TODO: read from a file and then populate this field
    return "1.6.3"


# def _verify_aws_cloud_credentials(self) -> None:
#     ensure_installed("aws")
#     try:
#         aws_caller_identity = boto3.client("sts").get_caller_identity()
#         configured_aws_account_id = aws_caller_identity["Account"]
#         required_aws_account_id = self.root().providers["aws"]["account_id"]
#         if required_aws_account_id != configured_aws_account_id:
#             raise UserErrors(
#                 "\nSystem configured AWS Credentials are different from the ones being used in the "
#                 f"Configuration. \nSystem is configured with credentials for account "
#                 f"{configured_aws_account_id} but the config requires the credentials for "
#                 f"{required_aws_account_id}."
#             )
#     except NoCredentialsError:
#         raise UserErrors(
#             "Unable to locate credentials.\n"
#             "Visit `https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html` "
#             "for more information."
#         )
#     except ClientError as e:
#         raise UserErrors(
#             "The AWS Credentials are not configured properly.\n"
#             f" - Code: {e.response['Error']['Code']} Error Message: {e.response['Error']['Message']}"
#             "Visit `https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html` "
#             "for more information."
#         )
