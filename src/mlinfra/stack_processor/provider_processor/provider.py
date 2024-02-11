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

from abc import ABC, abstractmethod


class AbstractProvider(ABC):
    """
    Abstract class for providers
    """

    def __init__(self, stack_name: str, config: dict):
        """
        Initializes the AbstractProvider object with the provided stack name and configuration object.

        Args:
            stack_name (str): The name of the stack.
            config (dict): The configuration for the provider.
        """
        self.stack_name = stack_name
        self.config = config

    @abstractmethod
    def configure_provider(self):
        """
        Abstract method that needs to be implemented by subclasses to configure the provider.
        """
        pass
