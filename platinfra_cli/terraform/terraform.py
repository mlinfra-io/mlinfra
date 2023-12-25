"""
This file is responsible for configuring and running terraform commands
Plan function undergoes the following steps:
- checking if terraform is installed
- checking if following versions are correct:
    - terraform
    - mlops_cli
- checking if the platinfra config file exists
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
import os
import boto3
import json
import yaml
import subprocess
from botocore.config import Config
from platinfra_cli.utils.constants import TF_PATH
from platinfra_cli.terraform.state_helper import StateHelper
from platinfra_cli.stack_processor.stack_generator import StackGenerator
from platinfra_cli.utils.utils import terraform_tested_version, clean_tf_directory


class Terraform:
    """
    This class is responsible for running terraform commands
    """

    def __init__(self, stack_config_path: str):
        self.stack_config_path = stack_config_path

    def check_terraform_installed(self):
        """This function is responsible for checking if terraform is installed"""
        try:
            version = subprocess.check_output(
                ["terraform", "--version"], universal_newlines=True
            )
            installed_version = version.split("\n")[0]
            if installed_version in terraform_tested_version:
                return 0
        except Exception as e:
            return f"An error occurred while checking the Terraform version: {str(e)}"

    def check_config_file_exists(self):
        """This function is responsible for checking if the config file exists"""
        if not os.path.isfile(self.stack_config_path):
            raise FileNotFoundError(
                f"The file {self.stack_config_path} does not exist."
            )

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
            raise ValueError(
                f"The following keys are missing: {', '.join(missing_keys)}"
            )

    def clean_mlops_infra_folder(self, delete_dir: bool = True):
        """
        This function is responsible for cleaning the .mlops_infra folder
        if delete_dir is set to true, the folder will be deleted
        """
        if delete_dir:
            clean_tf_directory()
        else:
            print(
                "The param delete_dir is set as false, skipping the directory deletion"
            )

    def process_config_file(self):
        """This function is responsible for processing the config file"""
        file_processor = StackGenerator(stack_config_path=self.stack_config_path)
        file_processor.generate()

        return file_processor.get_state_file_name(), file_processor.get_region()

    def check_cloud_credentials(self):
        """This function is responsible for checking if the cloud credentials are present"""
        try:
            if not boto3.Session().get_credentials():
                raise ValueError("AWS credentials not found.")
        except Exception as e:
            raise ValueError(
                f"An error occurred while checking AWS credentials: {str(e)}"
            )

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

    def check_terraform_state_storage(self, state_name: str, aws_region: str):
        """This function is responsible for checking if the terraform state storage is present"""
        state_helper = StateHelper(
            state=state_name,
            region=aws_region,
        )

        state_helper.manage_aws_state_storage()

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

    def generate_terraform_config(self) -> (str, str):
        """This function is responsible for generating the terraform config file"""
        self.check_terraform_installed()
        # TODO: perform this after the cli package has been released
        # self.check_mlops_cli_installed()
        self.check_config_file_exists()
        self.clean_mlops_infra_folder()
        state_name, aws_region = self.process_config_file()
        return state_name, aws_region

    def plan(self):
        """
        This function is responsible for running terraform plan command
        along with couple of other preleminary checks
        """
        state_name, aws_region = self.generate_terraform_config()
        self.check_cloud_credentials()
        self.check_region_has_three_azs(aws_region=aws_region)
        self.check_terraform_state_storage(state_name=state_name, aws_region=aws_region)
        modules_list = self.generate_modules_list()
        return modules_list

    def apply(self):
        """
        This function is responsible for running terraform apply command
        """
        modules_list = self.plan()
        target_string = ""
        for item in modules_list:
            target_string += f" -target={item}"

        return target_string
