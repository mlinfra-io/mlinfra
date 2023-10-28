import json
import yaml
from abc import ABC, abstractmethod
from platinfra_cli.enums.provider import Provider
from platinfra_cli.enums.deployment_type import DeploymentType


class AbstractStack(ABC):
    """
    Abstract class for all stacks.
    """

    def __init__(
        self,
        state_file_name: str,
        region: str,
        account_id: str,
        provider: Provider,
        deployment_type: DeploymentType,
        stacks: yaml,
    ):
        """
        Initializes the stack.

        Args:
            provider (Provider): The cloud provider.
            stacks (yaml): The stack config.
        """
        self.state_file_name = state_file_name
        self.region = region
        self.account_id = account_id
        self.provider = provider
        self.deployment_type = deployment_type
        self.stacks = stacks

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
        with open(
            f"modules/applications/{stack_type}/{application_name}/{application_name}_{self.deployment_type.value}.{extension}",
            "r",
            encoding="utf-8",
        ) as tf_config:
            return (
                yaml.safe_load(tf_config.read())
                if extension == "yaml"
                else json.loads(tf_config.read())
            )

    @abstractmethod
    def process_stack_config():
        """
        Process the stack configuration and validates the config.
        """
        pass

    @abstractmethod
    def process_stack_inputs():
        """
        Process the stack inputs and validates the inputs.
        """
        pass

    @abstractmethod
    def process_stack_modules():
        """
        Generates the stack modules terraform json configuration
        and validates the modules against the stack config and parameters.
        """
        pass

    @abstractmethod
    def process_stack_outputs():
        """
        Generates the required stack outputs.
        """
        pass

    @abstractmethod
    def generate():
        """
        Generates the stack configuration.
        """
        pass
