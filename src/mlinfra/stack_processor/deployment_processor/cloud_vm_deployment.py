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
from importlib import resources
from typing import Any, Dict

from mlinfra import modules
from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.stack_processor.deployment_processor.deployment import (
    AbstractDeployment,
)
from mlinfra.utils.utils import generate_tf_json


class CloudVMDeployment(AbstractDeployment):
    """
    A class that configures the deployment of cloud infrastructure resources based on the specified provider.

    Args:
        stack_name (str): The name of the stack.
        provider (CloudProvider): The cloud provider (AWS, GCP, or Azure).
        region (str): The region where the resources will be deployed.
        deployment_config (Dict[str, Any]): The deployment configuration in dictionary format.
    """

    def __init__(
        self,
        stack_name: str,
        provider: CloudProvider,
        region: str,
        deployment_config: Dict[str, Any],
    ):
        super().__init__(stack_name, provider, region, deployment_config)

    def configure_required_provider_config(self):
        """
        Configures the required provider configuration for the deployment.
        Updates the Terraform JSON file with the necessary provider information.
        """

        with open(
            resources.files(modules) / f"cloud/{self.provider.value}/terraform.tf.json",
            "r",
        ) as data_json:
            data = json.load(data_json)

            # add random provider
            with open(
                resources.files(modules)
                / f"cloud/{self.provider.value}/terraform_providers/random/terraform.tf.json",
                "r",
            ) as random_tf:
                random_tf_json = json.load(random_tf)
            data["terraform"]["required_providers"].update(
                random_tf_json["terraform"]["required_providers"]
            )

            data["terraform"].update(self.get_provider_backend(provider=self.provider))

            generate_tf_json(module_name="terraform", json_module=data)

    def configure_deployment_config(self):
        """
        Configures the deployment configuration based on the provider.
        Generates a Terraform JSON file for the specific provider.
        """
        if self.provider == CloudProvider.AWS:
            json_module = {
                "module": {
                    "vpc": {
                        "name": f"{self.stack_name}-vpc",
                        "source": "./modules/cloud/aws/vpc",
                    }
                }
            }
            vpc_config = self.deployment_config.get("config", {}).get("vpc", {})
            json_module["module"]["vpc"].update(vpc_config)

            generate_tf_json(module_name="vpc", json_module=json_module)
        elif self.provider == CloudProvider.GCP:
            pass
        elif self.provider == CloudProvider.AZURE:
            pass
        else:
            raise ValueError(f"Provider {self.provider} is not supported")

    def configure_deployment(self):
        """
        Configures the deployment by calling the `configure_required_provider_config()` and `configure_deployment_config()` methods.
        """
        self.configure_required_provider_config()
        self.configure_deployment_config()


if __name__ == "__main__":
    pass
