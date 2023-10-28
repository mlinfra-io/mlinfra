import json
from platinfra_cli.enums.provider import Provider
from platinfra_cli.stack_processor.deployment_processor.deployment import (
    AbstractDeployment,
)
from platinfra_cli.utils.constants import TF_PATH


class CloudInfraDeployment(AbstractDeployment):
    def __init__(
        self,
        stack_name: str,
        provider: Provider,
        region: str,
    ):
        super().__init__(
            stack_name=stack_name,
            provider=provider,
            region=region,
        )

    def configure_deployment(self):
        with open(
            f"modules/cloud/{self.provider.value}/terraform.tf.json", "r"
        ) as data_json:
            with open(
                f"./{TF_PATH}/terraform.tf.json", "w", encoding="utf-8"
            ) as tf_json:
                data = json.load(data_json)

                # add random provider
                with open(
                    "modules/terraform_providers/random/terraform.tf.json", "r"
                ) as random_tf:
                    random_tf_json = json.load(random_tf)
                data["terraform"]["required_providers"].update(
                    random_tf_json["terraform"]["required_providers"]
                )

                data["terraform"].update(
                    self.get_provider_backend(provider=self.provider)
                )

                json.dump(data, tf_json, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    pass
