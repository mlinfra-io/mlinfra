#     Copyright (c) mlinfra 2024. All Rights Reserved.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at:
#         https://www.apache.org/licenses/LICENSE-2.0
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#     or implied. See the License for the specific language governing
#     permissions and limitations under the License.

import json
import os
import re
import shutil

# TODO: Update this section to run it more secure and
# remove the comment
import subprocess  # nosec
import sys
from typing import List

from rich.traceback import install as rich_tr_install

from .constants import TF_PATH


def clean_tf_directory():
    if os.path.isdir(TF_PATH):
        shutil.rmtree(TF_PATH)


def generate_tf_json(module_name: str, json_module: json):
    with open(f"./{TF_PATH}/{module_name}.tf.json", "w", encoding="utf-8") as tf_json:
        json.dump(json_module, tf_json, ensure_ascii=False, indent=2)


def check_terraform_installed():
    try:
        # TODO: Update this section to run it more secure and
        # remove the comment
        result = run_command(["terraform", "--version"])

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


# TODO: create symlink of only respective provider for the deployment type, not everything.
def create_symlinks(source: str, destination: str) -> None:
    """
    Create symlinks for all.tf and .tpl files in the source directory to the destination directory
    This also skips files starting with a dot (.)
    :param source: source directory
    :param destination: destination directory

    :return: None
    """
    if not os.path.exists(destination):
        os.makedirs(destination)

    for item in os.listdir(source):
        if item.startswith("."):
            continue
        source_item = os.path.join(source, item)
        destination_item = os.path.join(destination, item)

        if os.path.isdir(source_item):
            create_symlinks(source_item, destination_item)
        elif os.path.isfile(source_item) and (
            source_item.endswith(".tf")
            or source_item.endswith(".tpl")
            or re.search(r".*values\.yaml", source_item)
        ):
            if not os.path.exists(destination_item):
                os.symlink(source_item, destination_item)


def terraform_tested_version():
    # TODO: read from a file and then populate this field
    return "1.10.2"


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


def run_command(
    command: List[str],
    universal_newlines: bool = True,
    capture_output: bool = True,
    text: bool = True,
    check: bool = True,
    timeout: float | None = None,
) -> List[str]:
    """
    This function runs a command in the subprocess and returns the result.

    Args:
        command: List of command arguments to run.
        universal_newlines: Whether to use universal newlines mode.
        capture_output: Whether to capture the output of the command.
        text: Whether to treat the output as text.
        check: Whether to raise an exception if the command exits with a non-zero status.
        timeout: Timeout in seconds for the command.

    Returns:
        The result of the command execution.
    """
    return subprocess.run(  # nosec
        command,
        universal_newlines=universal_newlines,
        capture_output=capture_output,
        text=text,
        check=check,
        timeout=timeout,
    )


def check_docker_installed():
    """
    This function is responsible for checking if docker is installed
    """
    try:
        version = run_command(["docker", "--version"])
        if not version:
            return 1
    except Exception as e:
        return f"An error occurred while checking the docker version. {str(e)}"


def check_kind_installed():
    """
    This function is responsible for checking if kind is installed
    """
    try:
        version = run_command(["kind", "--version"])
        if not version:
            return 1
    except Exception as e:
        return f"An error occurred while checking the kind version. {str(e)}"


def check_minikube_installed():
    """
    This function is responsible for checking if minikube cli is installed
    """
    try:
        version = run_command(["minikube", "version"])
        if not version:
            return 1
    except Exception as e:
        return f"An error occurred while checking the minikube version. {str(e)}"


def safe_run(func):  # type: ignore
    def func_wrapper(*args, **kwargs):  # type: ignore
        try:
            return func(*args, **kwargs)
        except Exception as e:
            if hasattr(sys, "_called_from_test"):
                raise e
            else:
                print(e)
                return None

    return func_wrapper


def setup_rich_traceback(debug_mode: bool = False):
    if debug_mode:
        rich_tr_install(show_locals=True)
    else:
        rich_tr_install(show_locals=False, suppress=[subprocess])
