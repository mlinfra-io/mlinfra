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
from mlinfra.stack_processor.deployment_processor.cloud_vm_deployment import (
    CloudVMDeployment,
)
from mlinfra.stack_processor.deployment_processor.kind_deployment import KindDeployment
from mlinfra.stack_processor.deployment_processor.kubernetes_deployment import (
    KubernetesDeployment,
)
from mlinfra.stack_processor.deployment_processor.minikube_deployment import MiniKubeDeployment
from mlinfra.stack_processor.provider_processor.aws_provider import (
    AWSProvider,
)
from mlinfra.stack_processor.provider_processor.local_provider import LocalProvider
from mlinfra.stack_processor.stack_processor.cloud_vm_stack import (
    CloudVMStack,
)
from mlinfra.stack_processor.stack_processor.kubernetes_stack import (
    KubernetesStack,
)
from mlinfra.stack_processor.stack_processor.local_stack import LocalStack


class StackGenerator:
    """
    A class that generates and configures infrastructure stacks based on the provided stack configuration.

    Attributes:
        stack_config (dict): The stack configuration provided to the StackGenerator object.
        stack_name (str): The name of the stack.
        account_id (str): The account ID associated with the stack.
        provider (str): The cloud provider for the stack.
        deployment_type (str): The type of deployment (cloud infrastructure or Kubernetes).
        state_file_name (str): The name of the state file.
        is_stack_component (bool): A flag indicating if the stack is a component of a larger stack.
        output (dict): The output configuration for the stack.
    """

    def __init__(self, stack_config):
        """
        Initializes the StackGenerator object with the provided stack configuration.

        Args:
            stack_config (dict): The stack configuration provided to the StackGenerator object.

        Raises:
            Exception: If the stack configuration is missing any required components.
        """
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
        self.region = self.stack_config["provider"].get("region", "")
        self.provider = self.configure_provider()

    # TODO: refactor statefile name
    def get_state_file_name(self):
        """
        Generates the state file name based on the stack name and region.

        Returns:
            str: The state file name.
        """
        self.state_file_name = f"tfstate-{self.stack_name}-{self.region}"
        return self.state_file_name

    def get_region(self) -> str:
        """
        Returns the region specified in the stack configuration.

        Returns:
            str: The region.
        """
        return self.region

    def get_provider(self) -> str:
        """
        Returns the provider type

        Returns:
            str: The provider type.
        """
        return self.provider

    def get_stack_name(self) -> str:
        """
        Returns the stack name.

        Returns:
            str: The stack name.
        """
        return self.stack_name

    def generate(self):
        """
        Generates and configures the infrastructure stacks based on the deployment type.
        """
        deployment_type = self.stack_config["deployment"]["type"]

        if deployment_type == DeploymentType.CLOUD_VM.value:
            CloudVMDeployment(
                stack_name=self.stack_name,
                provider=CloudProvider(self.stack_config["provider"]["name"]),
                region=self.region,
                deployment_config=self.stack_config["deployment"],
            ).configure_deployment()

            CloudVMStack(
                state_file_name=self.state_file_name,
                region=self.region,
                account_id=self.account_id,
                provider=self.provider,
                deployment_type=DeploymentType.CLOUD_VM,
                stacks=self.stack_config["stack"],
            ).generate()

        elif deployment_type == DeploymentType.KUBERNETES.value:
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

        elif deployment_type == DeploymentType.KIND.value:
            KindDeployment(
                stack_name=self.stack_name,
                provider=CloudProvider(self.stack_config["provider"]["name"]),
                region=self.region,
                deployment_config=self.stack_config["deployment"],
            ).configure_deployment()

            LocalStack(
                state_file_name=self.state_file_name,
                region=self.region,
                account_id=self.account_id,
                provider=self.provider,
                deployment_type=DeploymentType.KIND,
                stacks=self.stack_config["stack"],
            ).generate()

        elif deployment_type == DeploymentType.MINIKUBE.value:
            MiniKubeDeployment(
                stack_name=self.stack_name,
                provider=CloudProvider(self.stack_config["provider"]["name"]),
                region=self.region,
                deployment_config=self.stack_config["deployment"],
            ).configure_deployment()

            LocalStack(
                state_file_name=self.state_file_name,
                region=self.region,
                account_id=self.account_id,
                provider=self.provider,
                deployment_type=DeploymentType.MINIKUBE,
                stacks=self.stack_config["stack"],
            ).generate()

        else:
            raise ValueError(f"Deployment type {deployment_type} not supported")

    def configure_provider(self) -> CloudProvider:
        """
        Configures the provider details based on the stack configuration.

        Returns:
            CloudProvider: The cloud provider.

        Raises:
            NotImplementedError: If the cloud provider is not supported.
        """
        provider_name = self.stack_config["provider"]["name"]
        if provider_name == CloudProvider.AWS.value:
            aws_provider = AWSProvider(
                stack_name=self.stack_name, config=self.stack_config["provider"]
            )
            aws_provider.configure_provider()
            return CloudProvider.AWS
        elif provider_name == CloudProvider.LOCAL.value:
            local_provider = LocalProvider(
                stack_name=self.stack_name,
                config=self.stack_config["provider"],
                deployment=self.stack_config["deployment"],
            )
            local_provider.configure_provider()
            return CloudProvider.LOCAL
        else:
            raise NotImplementedError("Cloud provider not supported")
