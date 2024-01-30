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

import yaml
from mlinfra import absolute_project_root
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
            absolute_project_root()
            / f"modules/applications/{self.deployment_type.value}/{stack_type}/{application_name}/{application_name}_{self.deployment_type.value}.{extension}",
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
