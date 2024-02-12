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
from mlinfra.stack_processor.provider_processor.provider import AbstractProvider


class TestAbstractProvider:
    # AbstractProvider object can be initialized with stack name and configuration object.
    def test_initialize_with_stack_name_and_config(self):
        stack_name = "test_stack"
        config = {"key": "value"}

        class ConcreteProvider(AbstractProvider):
            def configure_provider(self):
                pass

        provider = ConcreteProvider(stack_name, config)

        assert provider.stack_name == stack_name
        assert provider.config == config

    # Subclasses can implement configure_provider method to configure the provider.
    def test_configure_provider_method(self):
        class TestProvider(AbstractProvider):
            def configure_provider(self):
                return "Provider configured"

        provider = TestProvider("test_stack", {"key": "value"})

        assert provider.configure_provider() == "Provider configured"

    # stack_name parameter is not provided during initialization.
    def test_missing_stack_name_parameter(self):
        with pytest.raises(TypeError):
            AbstractProvider(config={"key": "value"})

    # config parameter is not provided during initialization.
    def test_missing_config_parameter(self):
        with pytest.raises(TypeError):
            AbstractProvider(stack_name="test_stack")

    # Subclasses can override __init__ method to add additional parameters.
    def test_subclass_override_init_method(self):
        class TestProvider(AbstractProvider):
            def __init__(self, stack_name, config, additional_param):
                super().__init__(stack_name, config)
                self.additional_param = additional_param

            def configure_provider(self):
                pass

        provider = TestProvider("test_stack", {"key": "value"}, "additional")

        assert provider.stack_name == "test_stack"
        assert provider.config == {"key": "value"}
        assert provider.additional_param == "additional"
