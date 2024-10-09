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

from mlinfra import modules
from mlinfra.stack_processor.provider_processor.provider import (
    AbstractProvider,
)
from mlinfra.utils.constants import TF_PATH


class LocalProvider(AbstractProvider):
    """
    Represents provider for Local provider clusters
    """

    def __init__(self, stack_name: str, config: dict, deployment: dict):
        """
        Inits the Local Provider
        """
        super().__init__(stack_name, config)
        self.deployment = deployment

    def configure_provider(self):
        """
        Configures Local provider
        """
        with open(
            resources.files(modules) / f"local/{self.deployment['type']}/provider.tf.json", "r"
        ) as data_json:
            with open(f"./{TF_PATH}/provider.tf.json", "w", encoding="utf-8") as tf_json:
                data = json.load(data_json)
                json.dump(data, tf_json, ensure_ascii=False, indent=2)
