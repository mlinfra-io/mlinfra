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

import yaml
from mlinfra import relative_project_root
from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.stack_processor.deployment_processor.deployment import (
    AbstractDeployment,
)
from mlinfra.utils.utils import generate_tf_json


class CloudInfraDeployment(AbstractDeployment):
    def __init__(
        self,
        stack_name: str,
        provider: CloudProvider,
        region: str,
        deployment_config: yaml,
    ):
        super(CloudInfraDeployment, self).__init__(
            stack_name=stack_name,
            provider=provider,
            region=region,
            deployment_config=deployment_config,
        )

    def configure_required_provider_config(self):
        with open(
            relative_project_root() / f"modules/cloud/{self.provider.value}/terraform.tf.json",
            "r",
        ) as data_json:
            data = json.load(data_json)

            # add random provider
            with open(
                relative_project_root() / "modules/terraform_providers/random/terraform.tf.json",
                "r",
            ) as random_tf:
                random_tf_json = json.load(random_tf)
            data["terraform"]["required_providers"].update(
                random_tf_json["terraform"]["required_providers"]
            )

            data["terraform"].update(self.get_provider_backend(provider=self.provider))

            generate_tf_json(module_name="terraform", json_module=data)

    def configure_deployment_config(self):
        # inject vpc module
        if self.provider == CloudProvider.AWS:
            json_module = {"module": {"vpc": {}}}
            json_module["module"]["vpc"]["name"] = f"{self.stack_name}-vpc"
            json_module["module"]["vpc"]["source"] = "./modules/cloud/aws/vpc"

            if "config" in self.deployment_config and "vpc" in self.deployment_config["config"]:
                for vpc_config in self.deployment_config["config"]["vpc"]:
                    json_module["module"]["vpc"][vpc_config] = self.deployment_config["config"][
                        "vpc"
                    ].get(vpc_config, None)

            generate_tf_json(module_name="vpc", json_module=json_module)
        elif self.provider == CloudProvider.GCP:
            pass
        elif self.provider == CloudProvider.AZURE:
            pass
        else:
            raise ValueError(f"Provider {self.provider} is not supported")

    def configure_deployment(self):
        self.configure_required_provider_config()
        self.configure_deployment_config()


if __name__ == "__main__":
    pass
