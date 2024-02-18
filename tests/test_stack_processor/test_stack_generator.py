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
from mlinfra.stack_processor.stack_generator import StackGenerator


class TestStackGenerator:
    # Raises an exception if 'name', 'provider', 'deployment' or 'stack' keys are missing in 'stack_config'.
    def test_raises_exception_if_missing_keys(self):
        stack_config = {
            "provider": {"name": "aws", "region": "us-west-2"},
            "deployment": {"type": "cloud_vm"},
            "stack": [],
        }
        with pytest.raises(Exception):
            StackGenerator(stack_config)

    # TODO: Uncomment this and implement the feature
    # Raises an exception if the length of 'stack_name' attribute is greater than 37 characters.
    # def test_raises_exception_if_stack_name_exceeds_37_characters(self):
    #     stack_config = {
    #         "name": "a" * 38,
    #         "provider": {"name": "aws", "region": "us-west-2"},
    #         "deployment": {"type": "cloud_vm"},
    #         "stack": [],
    #     }
    #     with pytest.raises(Exception):
    #         StackGenerator(stack_config)

    # # Raises an exception if 'provider' key in 'stack_config' is not a valid CloudProvider enum value.
    def test_raises_exception_if_provider_key_is_invalid(self):
        stack_config = {
            "name": "test_stack",
            "provider": {"name": "invalid_provider", "region": "us-west-2"},
            "deployment": {"type": "cloud_vm"},
            "stack": [],
        }
        with pytest.raises(NotImplementedError):
            StackGenerator(stack_config)

    # TODO: think about moving validations in a better place
    # Raises an exception if 'deployment' key in 'stack_config' is not a valid DeploymentType enum value.
    # def test_raises_exception_if_deployment_key_is_invalid(self):
    #     stack_config = {
    #         "name": "test_stack",
    #         "provider": {"name": "aws", "region": "us-west-2"},
    #         "deployment": {"type": "invalid_deployment"},
    #         "stack": [],
    #     }
    #     with pytest.raises(ValueError):
    #         StackGenerator(stack_config).generate()
