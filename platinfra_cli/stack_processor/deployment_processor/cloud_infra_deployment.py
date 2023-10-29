import json
import yaml
from platinfra_cli.enums.provider import Provider
from platinfra_cli.stack_processor.deployment_processor.deployment import (
    AbstractDeployment,
)
from platinfra_cli.utils.utils import generate_tf_json


class CloudInfraDeployment(AbstractDeployment):
    def __init__(self, stack_name: str, provider: Provider, region: str, config: yaml):
        super(CloudInfraDeployment, self).__init__(
            stack_name=stack_name, provider=provider, region=region, config=config
        )

    def configure_required_provider_config(self):
        with open(
            f"modules/cloud/{self.provider.value}/terraform.tf.json", "r"
        ) as data_json:
            data = json.load(data_json)

            # add random provider
            with open(
                "modules/terraform_providers/random/terraform.tf.json", "r"
            ) as random_tf:
                random_tf_json = json.load(random_tf)
            data["terraform"]["required_providers"].update(
                random_tf_json["terraform"]["required_providers"]
            )

            data["terraform"].update(self.get_provider_backend(provider=self.provider))

            generate_tf_json(module_name="terraform", json_module=data)

    def configure_deployment_config(self):
        # inject vpc module
        if self.provider == Provider.AWS:
            json_module = {"module": {"vpc": {}}}
            json_module["module"]["vpc"]["name"] = f"{self.stack_name}-vpc"
            json_module["module"]["vpc"]["source"] = "../modules/cloud/aws/vpc"

            if "config" in self.config and "vpc" in self.config["config"]:
                for vpc_config in self.config["config"]["vpc"]:
                    json_module["module"]["vpc"][vpc_config] = self.config["config"][
                        "vpc"
                    ].get(vpc_config, None)

            generate_tf_json(module_name="vpc", json_module=json_module)
        elif self.provider == Provider.GCP:
            pass
        elif self.provider == Provider.AZURE:
            pass
        else:
            raise ValueError(f"Provider {self.provider} is not supported")

    def configure_deployment(self):
        self.configure_required_provider_config()
        self.configure_deployment_config()


if __name__ == "__main__":
    pass
