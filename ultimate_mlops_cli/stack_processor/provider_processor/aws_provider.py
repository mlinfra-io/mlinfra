import json
import yaml
from ultimate_mlops_cli.stack_processor.provider_processor.provider import (
    AbstractProvider,
)
from ultimate_mlops_cli.utils.constants import TF_PATH


class AWSProvider(AbstractProvider):
    def __init__(self, stack_name: str, config: yaml):
        super().__init__(stack_name=stack_name, config=config)

    def get_provider_details(self) -> (str, str):
        super().get_provider_details()
        return (self.account_id, self.region)

    def get_access_credentials(self) -> (str, str):
        return (self.access_key, self.secret_key)

    def get_role_arn(self) -> str:
        return self.role_arn

    def configure_provider(self):
        with open("modules/cloud/aws/provider.tf.json", "r") as data_json:
            with open(
                f"./{TF_PATH}/provider.tf.json", "w", encoding="utf-8"
            ) as tf_json:
                data = json.load(data_json)
                data["provider"]["aws"]["region"] = self.region
                data["provider"]["aws"]["allowed_account_ids"] = [self.account_id]
                data["provider"]["aws"]["default_tags"]["tags"]["region"] = self.region
                data["provider"]["aws"]["default_tags"]["tags"][
                    "stack"
                ] = self.stack_config_path

                # TODO: Add assume role block if applicable

                # add random provider
                with open(
                    "modules/terraform_providers/random/provider.tf.json", "r"
                ) as random_provider:
                    random_provider_json = json.load(random_provider)
                data["provider"].update(random_provider_json["provider"])

                json.dump(data, tf_json, ensure_ascii=False, indent=2)

        with open("modules/cloud/aws/data.tf.json", "r") as data_json:
            with open(f"./{TF_PATH}/data.tf.json", "w", encoding="utf-8") as tf_json:
                json_data = json.load(data_json)

                json_data["data"]["terraform_remote_state"] = {
                    "backend": "s3",
                    "config": {
                        "bucket": self.stack_name,
                        "key": "ultimate-mlops-stack",
                        "dynamodb_table": self.stack_name,
                        "region": self.region,
                    },
                }
                json.dump(json_data, tf_json, ensure_ascii=False, indent=2)
