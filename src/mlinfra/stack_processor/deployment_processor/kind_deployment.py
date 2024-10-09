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

import yaml
from mlinfra import modules
from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.stack_processor.deployment_processor.deployment import (
    AbstractDeployment,
)
from mlinfra.utils.utils import generate_tf_json


class KindDeployment(AbstractDeployment):
    def __init__(
        self,
        stack_name: str,
        provider: CloudProvider,
        region: str,
        deployment_config: yaml,
    ):
        """
        Initialize a new instance of the KindDeployment class.

        Parameters:
        - stack_name (str): The name of the stack.
        - provider (CloudProvider): The cloud provider for the deployment.
        - region (str): The region for the deployment. Empty string for KinD Cluster
        - deployment_config (yaml): The deployment configuration.
        """
        super(KindDeployment, self).__init__(
            stack_name=stack_name,
            provider=provider,
            region="",
            deployment_config=deployment_config,
        )

    def generate_required_provider_config(self):
        """
        Generate the required provider configuration for the Kubernetes deployment.

        This method reads the necessary provider configuration files and generates the required provider configuration for the Kubernetes deployment.
        It updates the 'terraform.tf.json' file with the required provider information.

        Parameters:
        - None

        Returns:
        - None
        """
        with open(
            resources.files(modules)
            / f"{self.provider.value}/{self.deployment_config['type']}/terraform.tf.json",
            "r",
        ) as data_json:
            data = json.load(data_json)

            # TODO: Update token generation for all providers
            required_providers = ["random", "kubernetes", "helm"]

            for required_provider in required_providers:
                with open(
                    resources.files(modules)
                    / f"local/terraform_providers/{required_provider}/terraform.tf.json",
                    "r",
                ) as provider_tf:
                    provider_tf_json = json.load(provider_tf)
                data["terraform"]["required_providers"].update(
                    provider_tf_json["terraform"]["required_providers"]
                )

            data["terraform"].update(self.get_provider_backend(provider=self.provider))

            generate_tf_json(module_name="terraform", json_module=data)

    def generate_k8s_helm_provider_config(self):
        data = {"provider": {}}

        # TODO: Update token generation for all providers
        providers = ["kubernetes", "helm"]

        for provider in providers:
            with open(
                resources.files(modules) / f"local/terraform_providers/{provider}/provider.tf.json",
                "r",
            ) as provider_tf:
                provider_tf_json = json.load(provider_tf)
                if provider == "kubernetes":
                    provider_tf_json["provider"]["kubernetes"]["client_certificate"] = (
                        "${ module.kind.client_certificate }"
                    )
                    provider_tf_json["provider"]["kubernetes"]["client_key"] = (
                        "${ module.kind.client_key }"
                    )
                    provider_tf_json["provider"]["kubernetes"]["cluster_ca_certificate"] = (
                        "${ module.kind.cluster_ca_certificate }"
                    )
                    provider_tf_json["provider"]["kubernetes"]["host"] = "${ module.kind.endpoint }"
                else:
                    provider_tf_json["provider"]["helm"]["kubernetes"]["client_certificate"] = (
                        "${ module.kind.client_certificate }"
                    )
                    provider_tf_json["provider"]["helm"]["kubernetes"]["client_key"] = (
                        "${ module.kind.client_key }"
                    )
                    provider_tf_json["provider"]["helm"]["kubernetes"]["cluster_ca_certificate"] = (
                        "${ module.kind.cluster_ca_certificate }"
                    )
                    provider_tf_json["provider"]["helm"]["kubernetes"]["host"] = (
                        "${ module.kind.endpoint }"
                    )
            data["provider"].update(provider_tf_json["provider"])

        generate_tf_json(module_name="k8s_provider", json_module=data)

    def generate_deployment_config(self):
        """
        Generate the deployment configuration for the Kubernetes deployment.

        This method generates the deployment configuration for the Kubernetes deployment based on the specified provider.
        It injects the necessary modules and configurations into the Terraform configuration files.

        Parameters:
        - None

        Returns:
        - None

        Raises:
        - ValueError: If the specified provider is not supported.
        """

        # inject k8s module
        k8s_json_module = {"module": {"kind": {}}}
        k8s_json_module["module"]["kind"]["source"] = (
            f"./modules/{self.provider.value}/{self.deployment_config['type']}/k8s/tf_module"
        )
        k8s_json_module["module"]["kind"]["cluster_name"] = f"{self.stack_name}-cluster"

        if "config" in self.deployment_config and "kubernetes" in self.deployment_config["config"]:
            # read values from the yaml config file
            with open(
                resources.files(modules) / f"local/{self.deployment_config['type']}/k8s/k8s.yaml",
                "r",
                encoding="utf-8",
            ) as tf_config:
                k8s_application_config = yaml.safe_load(tf_config.read())

            # check if values exist in the yaml config file
            if (
                k8s_application_config is not None
                and "inputs" in k8s_application_config
                and k8s_application_config["inputs"]
            ):
                # iterate through the config defined in the deployment section
                # of the stack file
                for k8s_config in self.deployment_config["config"]["kubernetes"]:
                    # if the application config exists in the kind config and is
                    # configured to be user_facing, only then add this config
                    config_lookup = next(
                        (
                            item
                            for item in k8s_application_config["inputs"]
                            if item["name"] == k8s_config and item["user_facing"]
                        ),
                        None,
                    )
                    if config_lookup is not None:
                        k8s_json_module["module"]["kind"][k8s_config] = self.deployment_config[
                            "config"
                        ]["kubernetes"].get(k8s_config, None)
                    else:
                        print(
                            """
                            WARNING: The config value {k8s_config} is not user facing.
                            Please check the k8s.yaml config file to see if this is a valid config value.
                            """
                        )

        generate_tf_json(module_name="kind", json_module=k8s_json_module)

    def configure_deployment(self):
        self.generate_required_provider_config()
        self.generate_k8s_helm_provider_config()
        self.generate_deployment_config()


if __name__ == "__main__":
    pass
