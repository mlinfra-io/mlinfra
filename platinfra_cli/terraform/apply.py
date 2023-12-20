"""
This file is responsible for configuring and running terraform `apply` command
Apply function undergoes the following steps:
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
import yaml
import subprocess
from platinfra_cli.terraform import Terraform
from platinfra_cli.utils.utils import terraform_tested_version
from platinfra_cli.stack_processor import StackGenerator
from platinfra_cli.terraform.terraform_state_helper import TerraformStateHelper


class Apply(Terraform):
    def __init__(self, config_file_path: yaml):
        self.config_file_path = config_file_path

    def apply(self):
        """
        This function is responsible for running terraform apply command
        """
        self.check_terraform_installed()
        self.check_mlops_cli_installed()
        self.check_config_file_exists()
        self.clean_mlops_infra_folder()
        self.check_cloud_credentials()
        self.check_region_has_three_azs()
        self.check_terraform_state_storage()
        self.process_config_file()
        self.terraform_apply()

    def check_terraform_installed(self):
        try:
            version = subprocess.check_output(
                ["terraform", "--version"], universal_newlines=True
            )
            installed_version = version.split("\n")[0]
            if installed_version in terraform_tested_version:
                return 0
        except Exception as e:
            return f"An error occurred while checking the Terraform version: {str(e)}"

    def process_config_file(self):
        file_processor = StackGenerator(stack_config_path=self.stack_config_path)

        state_helper = TerraformStateHelper(
            state=file_processor.get_state_file_name(),
            region=file_processor.get_region(),
        )
        state_helper.manage_aws_state_storage()

        file_processor.generate()
