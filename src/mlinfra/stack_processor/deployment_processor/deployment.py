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
from abc import ABC, abstractmethod

import yaml
from mlinfra.enums.cloud_provider import CloudProvider


class AbstractDeployment(ABC):
    """
    Abstract class for deployment
    """

    def __init__(
        self,
        stack_name: str,
        provider: CloudProvider,
        region: str,
        deployment_config: yaml,
    ):
        self.stack_name = stack_name
        self.provider = provider
        self.region = region
        self.deployment_config = deployment_config

    @abstractmethod
    def configure_deployment(self):
        pass

    # TODO: refactor statefile name
    def get_statefile_name(self) -> str:
        return f"tfstate-{self.stack_name}-{self.region}"

    def get_provider_backend(self, provider: CloudProvider) -> json:
        if provider == CloudProvider.AWS:
            return {
                "backend": {
                    "s3": {
                        "bucket": self.get_statefile_name(),
                        "key": "ultimate-mlops-stack",
                        "dynamodb_table": self.get_statefile_name(),
                        "region": self.region,
                        "encrypt": True,
                    }
                }
            }
        # Add other providers here
        # return {}
