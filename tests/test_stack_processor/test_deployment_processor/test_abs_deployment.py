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

import pytest
import yaml
from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.stack_processor.deployment_processor.deployment import AbstractDeployment


class TestAbstractDeployment:
    # stack_name argument is None
    def test_stack_name_argument_is_none(self):
        stack_name = None
        provider = CloudProvider.AWS
        region = "us-west-2"

        yaml_config = """
        deployment:
            type: cloud_vm
        """
        deployment_config = yaml.safe_load(yaml_config)

        with pytest.raises(TypeError):
            AbstractDeployment(stack_name, provider, region, deployment_config)

    # region argument is None
    def test_region_argument_is_none(self):
        stack_name = "test_stack"
        provider = CloudProvider.AWS
        region = None

        yaml_config = """
        deployment:
            type: cloud_vm
        """
        deployment_config = yaml.safe_load(yaml_config)

        with pytest.raises(TypeError):
            AbstractDeployment(stack_name, provider, region, deployment_config)

    # deployment_config argument is None
    def test_deployment_config_argument_is_none(self):
        stack_name = "test_stack"
        provider = CloudProvider.AWS
        region = "us-west-2"
        deployment_config = None

        with pytest.raises(TypeError):
            AbstractDeployment(stack_name, provider, region, deployment_config)
