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
from abc import ABC, abstractmethod
from importlib import resources
from typing import Any, Dict, Union

import yaml
from mlinfra import modules
from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.enums.deployment_type import DeploymentType


class AbstractStack(ABC):
    """
    Abstract class for all stacks.
    """

    def __init__(
        self,
        state_file_name: str,
        region: str,
        account_id: str,
        provider: CloudProvider,
        deployment_type: DeploymentType,
        stacks: yaml,
    ):
        """
        Initializes the stack.

        Args:
            state_file_name (str): The name of the state file for the stack.
            region (str): The region where the stack will be deployed.
            account_id (str): The ID of the account associated with the stack.
            provider (CloudProvider): The cloud provider for the stack.
            deployment_type (DeploymentType): The type of deployment for the stack.
            stacks (yaml): The stack configuration in YAML format.
        """
        self.state_file_name = state_file_name
        self.region = region
        self.account_id = account_id
        self.provider = provider
        self.deployment_type = deployment_type
        self.stacks = stacks

    def _read_config_file(
        self, stack_type: str, application_name: str, extension: str = "yaml"
    ) -> Union[Dict, Any]:
        """
        Reads the config file for the application and returns the config
        as a JSON object for application config and YAML for stack config.

        Args:
            stack_type (str): The type of the stack.
            application_name (str): The name of the application.
            extension (str, optional): The extension of the config file.

        Returns:
            Union[Dict, Any]: The configuration as a JSON object or YAML.
        """
        if self.provider.value == CloudProvider.LOCAL.value:
            file_path = (
                resources.files(modules)
                / f"applications/{self.provider.value}/{stack_type}/{application_name}/{application_name}.{extension}"
            )
        else:
            file_path = (
                resources.files(modules)
                / f"applications/{self.deployment_type.value}/{stack_type}/{application_name}/{application_name}_{self.deployment_type.value}.{extension}"
            )
        with open(file_path, "r", encoding="utf-8") as config_file:
            if extension == "yaml":
                return yaml.safe_load(config_file.read())
            else:
                return json.loads(config_file.read())

    @abstractmethod
    def process_stack_config(self):
        """
        Process the stack configuration and validates the config.
        """
        pass

    @abstractmethod
    def process_stack_inputs(self):
        """
        Process the stack inputs and validates the inputs.
        """
        pass

    @abstractmethod
    def process_stack_modules(self):
        """
        Generates the stack modules Terraform JSON configuration
        and validates the modules against the stack config and parameters.
        """
        pass

    @abstractmethod
    def process_stack_outputs(self):
        """
        Generates the required stack outputs.
        """
        pass

    @abstractmethod
    def generate(self):
        """
        Generates the stack configuration.
        """
        pass
