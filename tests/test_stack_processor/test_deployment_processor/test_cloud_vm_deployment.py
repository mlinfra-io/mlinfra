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

from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.stack_processor.deployment_processor.cloud_vm_deployment import CloudVMDeployment


class TestCloudVMDeployment:
    # can be instantiated with required parameters
    def test_instantiation(self):
        stack_name = "test_stack"
        provider = CloudProvider.AWS
        region = "us-west-2"
        deployment_config = {"config": {"vpc": {"cidr_block": "10.0.0.0/16"}}}

        deployment = CloudVMDeployment(stack_name, provider, region, deployment_config)

        assert deployment.stack_name == stack_name
        assert deployment.provider == provider
        assert deployment.region == region
        assert deployment.deployment_config == deployment_config

    # can configure deployment for AWS provider
    def test_configure_aws_deployment(self, mocker):
        stack_name = "test_stack"
        provider = CloudProvider.AWS
        region = "us-west-2"
        deployment_config = {"config": {"vpc": {"cidr_block": "10.0.0.0/16"}}}

        deployment = CloudVMDeployment(stack_name, provider, region, deployment_config)

        mocker.patch.object(deployment, "configure_required_provider_config")
        mocker.patch.object(deployment, "configure_deployment_config")

        deployment.configure_deployment()

        deployment.configure_required_provider_config.assert_called_once()
        deployment.configure_deployment_config.assert_called_once()
