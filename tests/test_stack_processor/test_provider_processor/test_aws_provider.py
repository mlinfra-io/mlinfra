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

from mlinfra.stack_processor.provider_processor.aws_provider import AWSProvider


class TestAWSProvider:
    # AWSProvider can be instantiated with a stack name and a configuration object
    def test_instantiation_with_stack_name_and_config(self):
        stack_name = "test_stack"
        config = {"account_id": "123456789", "region": "us-west-2"}
        provider = AWSProvider(stack_name, config)

        assert provider.stack_name == stack_name
        assert provider.config == config
        assert provider.account_id == config["account_id"]
        assert provider.region == config["region"]
        assert provider.access_key is None
        assert provider.secret_key is None
        assert provider.role_arn is None

    # AWSProvider can retrieve the name of the statefile for a given stack and region
    def test_get_statefile_name(self):
        stack_name = "test_stack"
        config = {"account_id": "123456789", "region": "us-west-2"}
        provider = AWSProvider(stack_name, config)

        expected_statefile_name = f"tfstate-{stack_name}-{config['region']}"

        assert provider.get_statefile_name() == expected_statefile_name

    # AWSProvider can be instantiated with a configuration object that does not contain an access key, a secret key, or a role ARN
    def test_instantiation_without_access_key_secret_key_role_arn(self):
        stack_name = "test_stack"
        config = {"account_id": "123456789", "region": "us-west-2"}
        provider = AWSProvider(stack_name, config)

        assert provider.stack_name == stack_name
        assert provider.config == config
        assert provider.account_id == config["account_id"]
        assert provider.region == config["region"]
        assert provider.access_key is None
        assert provider.secret_key is None
        assert provider.role_arn is None

    # AWSProvider can be instantiated with a configuration object that does not contain an account ID or a region
    def test_instantiation_without_account_id_region(self):
        stack_name = "test_stack"
        config = {"access_key": "access_key", "secret_key": "secret_key", "role_arn": "role_arn"}
        provider = AWSProvider(stack_name, config)

        assert provider.stack_name == stack_name
        assert provider.config == config
        assert provider.account_id is None
        assert provider.region is None
        assert provider.access_key == config["access_key"]
        assert provider.secret_key == config["secret_key"]
        assert provider.role_arn == config["role_arn"]
