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

import yaml


class AbstractProvider(ABC):
    """
    Abstract class for providers
    """

    @abstractmethod
    def __init__(self, stack_name: str, config: yaml):
        self.stack_name = stack_name
        self.config = config

    @abstractmethod
    def configure_provider(self):
        pass
