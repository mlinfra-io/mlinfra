import json
import os
import yaml
from ultimate_mlops_cli.stack_processor.deployment_processor.cloud_infra_processor import (
    CloudInfraProcessor,
    KubernetesProcessor,
)

from ultimate_mlops_cli.stack_processor.provider_processor.aws_provider import (
    AWSProvider,
)

from ultimate_mlops_cli.enums.provider import Provider
from ultimate_mlops_cli.enums.deployment_type import DeploymentType
from ultimate_mlops_cli.utils.utils import clean_tf_directory
from ultimate_mlops_cli.utils.constants import TF_PATH


class BaseProcessor:
    def __init__(self, stack_config_path):
        self.stack_config_path = stack_config_path
        self.stack_config = self.read_stack_config()
        self.stack_name = ""
        self.account_id = ""
        self.provider = "aws"
        self.deployment_type = ""
        self.state_file_name = ""
        self.is_stack_component = True
        self.output = {"output": []}

        if (
            not self.stack_config["name"]
            or "provider" not in self.stack_config
            or "deployment_type" not in self.stack_config
            or "stacks" not in self.stack_config
        ):
            raise Exception("Stack config component is missing")

        # this has to be done now as the stack config is read
        # and the provider details are needed for the state file name
        # and the region
        self.read_provider_details()
        self.stack_name = self.stack_config["name"]
        self.state_file_name = f"tfstate-{self.stack_name}-{self.region}"

    def get_state_file_name(self):
        return self.state_file_name

    def get_region(self):
        return self.region

    def generate(self):
        if (
            DeploymentType(self.stack_config["deployment_type"])
            == DeploymentType.CLOUD_INFRA
        ):
            CloudInfraProcessor(config=self.stack_config["stacks"]).generate()
        elif (
            DeploymentType(self.stack_config["deployment_type"])
            == DeploymentType.KUBERNETES
        ):
            KubernetesProcessor(config=self.stack_config["deployment_type"]).generate()

    def read_stack_config(self) -> yaml:
        # clean the generated files directory
        clean_tf_directory()

        # create the stack folder
        os.makedirs(TF_PATH, mode=0o777)

        # read the stack config file
        try:
            with open(self.stack_config_path, "r") as stack_config:
                config = yaml.safe_load(stack_config.read())
            return config
        except FileNotFoundError:
            raise FileNotFoundError(
                f"Stack config file not found: {self.stack_config_path}"
            )

    def read_provider_details(self) -> None:
        if Provider(self.stack_config["provider"]["name"]) == Provider.AWS:
            aws_provider = AWSProvider(self.stack_config["provider"])
            self.provider = Provider(self.stack_config["provider"]["name"])
            self.account_id, self.region = aws_provider.get_provider_details()

    def _read_config_file(
        self, stack_type: str, application_name: str, extension: str = "yaml"
    ) -> json:
        """
        Reads the config file for the application and returns the config
        as a json object for application config and yaml for stack config.

        Args:
            stack_type (str): The type of the stack.
            application_name (str): The name of the application.
            extension (str, optional): The extension of the config file.
        """
        try:
            with open(
                f"modules/applications/{stack_type}/{application_name}/{application_name}_{self.deployment_type.value}.{extension}",
                "r",
                encoding="utf-8",
            ) as tf_config:
                if extension == "yaml":
                    return yaml.safe_load(tf_config.read())
                return json.loads(tf_config.read())
        except FileNotFoundError:
            raise FileNotFoundError(
                f"Config file not found: {application_name}_{self.deployment_type.value}.{extension}"
            )


if __name__ == "__main__":
    tf = BaseProcessor(stack_config_path="examples/aws-mlflow.yaml")
    tf.generate()
