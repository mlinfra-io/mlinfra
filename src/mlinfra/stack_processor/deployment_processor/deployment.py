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

from abc import ABC, abstractmethod

from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.utils.constants import TF_LOCAL_STATE_PATH


class AbstractDeployment(ABC):
    """
    Abstract class for deployment.

    Args:
        stack_name (str): The name of the deployment stack.
        provider (CloudProvider): The cloud provider for the deployment.
        region (str): The region for the deployment.
        deployment_config (dict): The deployment configuration.

    Attributes:
        stack_name (str): The name of the deployment stack.
        provider (CloudProvider): The cloud provider for the deployment.
        region (str): The region for the deployment.
        deployment_config (dict): The deployment configuration.
    """

    def __init__(
        self,
        stack_name: str,
        provider: CloudProvider,
        region: str,
        deployment_config: dict,
    ):
        self.stack_name = stack_name
        self.provider = provider
        self.region = region
        self.deployment_config = deployment_config

    @abstractmethod
    def configure_deployment(self):
        """
        Abstract method that must be implemented by subclasses to configure the deployment.
        """
        pass

    # TODO: refactor statefile name
    def get_statefile_name(self) -> str:
        """
        Get the name of the statefile for the deployment.

        Returns:
            str: The name of the statefile.
        """
        return f"tfstate-{self.stack_name}-{self.region}"

    def get_provider_backend(self, provider: CloudProvider) -> dict:
        """
        Get the backend configuration for the specified provider.

        Args:
            provider (CloudProvider): The cloud provider.

        Returns:
            json: The backend configuration.
        """
        if provider == CloudProvider.AWS:
            return {
                "backend": {
                    "s3": {
                        "bucket": self.get_statefile_name(),
                        "key": "ultimate-mlops-stack",
                        "use_lockfile": True,
                        "region": self.region,
                        "encrypt": True,
                    }
                }
            }
        elif provider == CloudProvider.LOCAL:
            return {
                "backend": {
                    "local": {
                        "path": f"{TF_LOCAL_STATE_PATH}/{self.stack_name}/terraform.tfstate",
                    }
                }
            }
        # Add other providers here
        # return {}
