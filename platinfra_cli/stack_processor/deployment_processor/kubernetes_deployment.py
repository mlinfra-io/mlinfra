import json
import yaml
from platinfra_cli.enums.provider import Provider
from platinfra_cli.stack_processor.deployment_processor.deployment import (
    AbstractDeployment,
)
from platinfra_cli.utils.utils import generate_tf_json


class KubernetesDeployment(AbstractDeployment):
    def __init__(
        self, stack_name: str, provider: Provider, region: str, deployment_config: yaml
    ):
        super(KubernetesDeployment, self).__init__(
            stack_name=stack_name,
            provider=provider,
            region=region,
            deployment_config=deployment_config,
        )

    def generate_required_provider_config(self):
        with open(
            f"modules/cloud/{self.provider.value}/terraform.tf.json", "r"
        ) as data_json:
            data = json.load(data_json)

            # TODO: Update token generation for all providers
            required_providers = ["random", "kubernetes", "helm"]

            for required_provider in required_providers:
                with open(
                    f"modules/terraform_providers/{required_provider}/terraform.tf.json",
                    "r",
                ) as provider_tf:
                    provider_tf_json = json.load(provider_tf)
                data["terraform"]["required_providers"].update(
                    provider_tf_json["terraform"]["required_providers"]
                )

            data["terraform"].update(self.get_provider_backend(provider=self.provider))

            generate_tf_json(module_name="terraform", json_module=data)

    def generate_deployment_config(self):
        if self.provider == Provider.AWS:
            # TODO: Make these blocks generic
            # inject vpc module
            vpc_json_module = {"module": {"vpc": {}}}
            vpc_json_module["module"]["vpc"]["source"] = "../modules/cloud/aws/vpc"
            vpc_json_module["module"]["vpc"]["name"] = f"{self.stack_name}-vpc"

            if (
                "config" in self.deployment_config
                and "vpc" in self.deployment_config["config"]
            ):
                for vpc_config in self.deployment_config["config"]["vpc"]:
                    vpc_json_module["module"]["vpc"][
                        vpc_config
                    ] = self.deployment_config["config"]["vpc"].get(vpc_config, None)

            generate_tf_json(module_name="vpc", json_module=vpc_json_module)

            # inject k8s module
            k8s_json_module = {"module": {"eks": {}}}
            k8s_json_module["module"]["eks"]["source"] = "../modules/cloud/aws/eks"
            k8s_json_module["module"]["eks"]["name"] = f"{self.stack_name}-k8s-cluster"

            if (
                "config" in self.deployment_config
                and "kubernetes" in self.deployment_config["config"]
            ):
                for k8s_config in self.deployment_config["config"]["kubernetes"]:
                    k8s_json_module["module"]["eks"][
                        k8s_config
                    ] = self.deployment_config["config"]["kubernetes"].get(
                        k8s_config, None
                    )

            generate_tf_json(module_name="eks", json_module=k8s_json_module)

        elif self.provider == Provider.GCP:
            pass
        elif self.provider == Provider.AZURE:
            pass
        else:
            raise ValueError(f"Provider {self.provider} is not supported")

    def configure_deployment(self):
        self.generate_required_provider_config()
        self.generate_deployment_config()


if __name__ == "__main__":
    pass
