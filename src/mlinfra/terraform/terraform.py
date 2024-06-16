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
from importlib import resources
from typing import Tuple

# import hashlib
import boto3
import yaml
from botocore.config import Config
from mlinfra import modules
from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.stack_processor.stack_generator import StackGenerator
from mlinfra.terraform.state_helper import StateHelper
from mlinfra.utils.constants import TF_LOCAL_STATE_PATH, TF_PATH
from mlinfra.utils.utils import (
    check_docker_installed,
    check_kind_installed,
    check_terraform_installed,
    clean_tf_directory,
    create_symlinks,
)


class Terraform:
    """
    This class is responsible for running terraform commands
    This file is responsible for configuring and running terraform commands
    Plan function undergoes the following steps:
    - checking if terraform is installed
    - checking if following versions are correct:
        - terraform
        - mlops_cli
    - checking if the mlinfra config file exists
    - clean .mlops_infra folder
    - check cloud credentials
    - check if region has three AZs
    - Generate terraform state storage
    - loop through items in config file
        - generate list of modules (should come from stack processor module)
        - create a different apply function for different deployment types
            - order modules in order of application
            - apply terraform modules with -target
    """

    def __init__(self, stack_config_path: str):
        self.stack_config_path = stack_config_path

    def check_config_file_exists(self):
        """This function is responsible for checking if the config file exists"""
        if not os.path.isfile(self.stack_config_path):
            raise FileNotFoundError(f"The file {self.stack_config_path} does not exist.")

        with open(self.stack_config_path, "r") as stream:
            try:
                data = yaml.safe_load(stream)
            except yaml.YAMLError as exc:
                print(exc)
                raise ValueError(f"{exc}")

        # check if all required keys are present in the config file
        required_keys = ["name", "provider", "deployment", "stack"]

        if not all(key in data for key in required_keys):
            missing_keys = [key for key in required_keys if key not in data]
            raise ValueError(f"The following keys are missing: {', '.join(missing_keys)}")

    def clean_ml_infra_folder(self, delete_dir: bool = True):
        """
        This function is responsible for cleaning the .mlops_infra folder
        if delete_dir is set to true, the folder will be deleted
        """
        if delete_dir:
            clean_tf_directory()
        else:
            print("The param delete_dir is set as false, skipping the directory deletion")

    def read_stack_config(self) -> yaml:
        # clean the generated files directory
        clean_tf_directory()

        # create the stack folder
        os.makedirs(TF_PATH, mode=0o777)
        create_symlinks(resources.files(modules), TF_PATH + "/modules")

        # TODO: generate hash of the stack config to not generate config all the time
        # sha256_hash = hashlib.sha256()

        # read the stack config file
        try:
            with open(self.stack_config_path, "r") as stack_config:
                config = yaml.safe_load(stack_config.read())

            # with open(stack_config, "rb") as stack_config_file:
            #     # Read and update hash in chunks of 4K
            #     for byte_block in iter(lambda: stack_config_file.read(4096), b""):
            #         sha256_hash.update(byte_block)
            #         stack_file_digest = sha256_hash.hexdigest()
            #
            # Check if a folder with the value of stack_file_digest already exists
            # if not, create a folder inside the TF_PATH with stack_file_digest as the name
            # os.makedirs(f"{TF_PATH}/{stack_file_digest}", mode=0o777)

            return config

        except FileNotFoundError:
            raise FileNotFoundError(f"Stack config file not found: {self.stack_config_path}")

    # TODO: write getters for state file name and region
    def process_config_file(self) -> Tuple[str, str, str, str]:
        """This function is responsible for processing the config file"""
        stack_processor = StackGenerator(stack_config=self.read_stack_config())
        stack_processor.generate()

        return (
            stack_processor.get_stack_name(),
            stack_processor.get_state_file_name(),
            stack_processor.get_region(),
            stack_processor.get_provider(),
        )

    def check_cloud_credentials(self):
        """This function is responsible for checking if the cloud credentials are present"""
        try:
            if not boto3.Session().get_credentials():
                raise ValueError("AWS credentials not found.")
        except Exception as e:
            raise ValueError(f"An error occurred while checking AWS credentials: {str(e)}")

    def check_region_has_three_azs(self, aws_region: str = "eu-central-1"):
        """This function is responsible for checking if the region has three availability zones"""
        ec2 = boto3.client("ec2", config=Config(region_name=aws_region))
        response = ec2.describe_availability_zones(
            Filters=[{"Name": "zone-type", "Values": ["availability-zone"]}]
        )
        azs = [
            zone["ZoneName"]
            for zone in response["AvailabilityZones"]
            if zone["RegionName"] == aws_region
        ]
        if len(azs) < 3:
            raise ValueError(
                f"""
                The region {aws_region} has less than three availability zones.
                You configured {aws_region}, which only has the availability zones: {azs}.
                Please choose a different region.
                """
            )

    # TODO: move this out of this class
    def check_terraform_state_storage(self, state_name: str, aws_region: str):
        """This function is responsible for checking if the terraform state storage is present"""
        state_helper = StateHelper(
            state=state_name,
            region=aws_region,
        )

        state_helper.manage_aws_state_storage()

    def check_local_state_storage(self, state_name: str):
        """
        This function is responsible for checking if the local state storage is present
        """
        os.makedirs(f"{TF_LOCAL_STATE_PATH}/{state_name}", mode=0o777, exist_ok=True)

    def generate_modules_list(self):
        """
        This function is responsible for generating a list of modules
        that will be applied via the -target function of terraform
        """
        modules_list = []
        for file in os.listdir(TF_PATH):
            if file.endswith(".tf.json"):
                with open(os.path.join(TF_PATH, file)) as json_file:
                    data = json.load(json_file)
                    if "module" in data:
                        key, _ = data["module"].popitem()
                        modules_list.append(f"module.{key}")
        return modules_list

    def generate_terraform_config(self) -> Tuple[str, str, str, str]:
        """This function is responsible for generating the terraform config file"""
        check_terraform_installed()
        # TODO: perform this after the cli package has been released
        # self.check_mlinfra_cli_installed()
        self.check_config_file_exists()
        self.clean_ml_infra_folder()
        stack_name, state_name, aws_region, provider_type = self.process_config_file()
        return stack_name, state_name, aws_region, provider_type

    def plan(self) -> str:
        """
        This function is responsible for running terraform plan command
        along with a couple of other preliminary checks.
        """
        stack_name, state_name, aws_region, provider_type = self.generate_terraform_config()
        if provider_type is not CloudProvider.LOCAL:
            self.check_cloud_credentials()
            self.check_region_has_three_azs(aws_region=aws_region)
            self.check_terraform_state_storage(state_name=state_name, aws_region=aws_region)
        else:
            check_kind_installed()
            check_docker_installed()
            # state name is set to stack as in local deployment, there is no
            # region and hence no state name.
            self.check_local_state_storage(state_name=stack_name)
        modules_list = self.generate_modules_list()
        return "".join(f" -target={item}" for item in modules_list)
