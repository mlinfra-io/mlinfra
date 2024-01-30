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
from mlinfra import absolute_project_root
from mlinfra.stack_processor.provider_processor.provider import (
    AbstractProvider,
)
from mlinfra.utils.constants import TF_PATH


class AWSProvider(AbstractProvider):
    def __init__(self, stack_name: str, config: yaml):
        super().__init__(stack_name=stack_name, config=config)
        # required
        self.account_id = config.get("account_id")
        self.region = config.get("region")

        # optional
        self.access_key = config.get("access_key", None)
        self.secret_key = config.get("secret_key", None)
        self.role_arn = config.get("role_arn", None)

    # TODO: refactor statefile name
    def get_statefile_name(self) -> str:
        return f"tfstate-{self.stack_name}-{self.region}"

    def configure_provider(self):
        with open(absolute_project_root() / "modules/cloud/aws/provider.tf.json", "r") as data_json:
            with open(f"./{TF_PATH}/provider.tf.json", "w", encoding="utf-8") as tf_json:
                data = json.load(data_json)
                data["provider"]["aws"]["region"] = self.region
                data["provider"]["aws"]["allowed_account_ids"] = [self.account_id]
                data["provider"]["aws"]["default_tags"]["tags"]["region"] = self.region
                # data["provider"]["aws"]["default_tags"]["tags"][
                #     "stack"
                # ] = self.stack_config_path

                # TODO: Add assume role block if applicable

                # add random provider
                with open(
                    absolute_project_root() / "modules/terraform_providers/random/provider.tf.json",
                    "r",
                ) as random_provider:
                    random_provider_json = json.load(random_provider)
                data["provider"].update(random_provider_json["provider"])

                json.dump(data, tf_json, ensure_ascii=False, indent=2)

        # TODO: check when to add this...

        # with open(absolute_project_root() / "modules/cloud/aws/data.tf.json", "r") as data_json:
        #     with open(f"./{TF_PATH}/data.tf.json", "w", encoding="utf-8") as tf_json:
        #         json_data = json.load(data_json)

        #         json_data["data"]["terraform_remote_state"] = {
        #             "parent": {
        #                 "backend": "s3",
        #                 "config": {
        #                     "bucket": self.get_statefile_name(),
        #                     "key": "ultimate-mlops-stack",
        #                     "dynamodb_table": self.get_statefile_name(),
        #                     "region": self.region,
        #                 },
        #             }
        #         }
        #         json.dump(json_data, tf_json, ensure_ascii=False, indent=2)
