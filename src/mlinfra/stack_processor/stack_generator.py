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

from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.enums.deployment_type import DeploymentType
from mlinfra.stack_processor.deployment_processor.cloud_infra_deployment import (
    CloudInfraDeployment,
)
from mlinfra.stack_processor.deployment_processor.kubernetes_deployment import (
    KubernetesDeployment,
)
from mlinfra.stack_processor.provider_processor.aws_provider import (
    AWSProvider,
)
from mlinfra.stack_processor.stack_processor.cloud_infra_stack import (
    CloudInfraStack,
)
from mlinfra.stack_processor.stack_processor.kubernetes_stack import (
    KubernetesStack,
)


class StackGenerator:
    def __init__(self, stack_config):
        self.stack_config = stack_config
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
            or "deployment" not in self.stack_config
            or "stack" not in self.stack_config
        ):
            raise Exception("Stack config component is missing")

        # this has to be done now as the stack config is read
        # and the provider details are needed for the state file name
        # and the region
        # TODO: Throw an error if the stack name exceeds 37 characters
        self.stack_name = self.stack_config["name"]
        self.region = self.stack_config["provider"]["region"]
        self.provider = self.configure_provider()

    # TODO: refactor statefile name
    def get_state_file_name(self):
        self.state_file_name = f"tfstate-{self.stack_name}-{self.region}"
        return self.state_file_name

    def get_region(self):
        return self.region

    def generate(self):
        if DeploymentType(self.stack_config["deployment"]["type"]) == DeploymentType.CLOUD_INFRA:
            CloudInfraDeployment(
                stack_name=self.stack_name,
                provider=CloudProvider(self.stack_config["provider"]["name"]),
                region=self.region,
                deployment_config=self.stack_config["deployment"],
            ).configure_deployment()

            CloudInfraStack(
                state_file_name=self.state_file_name,
                region=self.region,
                account_id=self.account_id,
                provider=self.provider,
                deployment_type=DeploymentType.CLOUD_INFRA,
                stacks=self.stack_config["stack"],
            ).generate()

        elif DeploymentType(self.stack_config["deployment"]["type"]) == DeploymentType.KUBERNETES:
            KubernetesDeployment(
                stack_name=self.stack_name,
                provider=CloudProvider(self.stack_config["provider"]["name"]),
                region=self.region,
                deployment_config=self.stack_config["deployment"],
            ).configure_deployment()
            KubernetesStack(
                state_file_name=self.state_file_name,
                region=self.region,
                account_id=self.account_id,
                provider=self.provider,
                deployment_type=DeploymentType.KUBERNETES,
                stacks=self.stack_config["stack"],
            ).generate()

    def configure_provider(self) -> CloudProvider:
        if CloudProvider(self.stack_config["provider"]["name"]) == CloudProvider.AWS:
            aws_provider = AWSProvider(
                stack_name=self.stack_name, config=self.stack_config["provider"]
            )
            aws_provider.configure_provider()
            return CloudProvider.AWS
