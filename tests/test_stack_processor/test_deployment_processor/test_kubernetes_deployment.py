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
from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.stack_processor.deployment_processor.kubernetes_deployment import KubernetesDeployment


class TestKubernetesDeployment:
    # can be instantiated with valid arguments
    def test_instantiation_with_valid_arguments(self):
        stack_name = "test-stack"
        provider = CloudProvider.AWS
        region = "us-west-2"
        deployment_config = {}

        deployment = KubernetesDeployment(stack_name, provider, region, deployment_config)

        assert deployment.stack_name == stack_name
        assert deployment.provider == provider
        assert deployment.region == region
        assert deployment.deployment_config == deployment_config

    def test_specified_provider_not_supported(self):
        provider = CloudProvider.GCP
        region = "us-west-2"
        stack_name = "my-stack"
        deployment_config = {
            "config": {
                "vpc": {
                    "cidr_block": "10.0.0.0/16",
                    "subnet_cidr_blocks": ["10.0.1.0/24", "10.0.2.0/24"],
                },
                "kubernetes": {
                    "cluster_version": "1.30",
                    "node_groups": [
                        {
                            "name": "worker-group",
                            "instance_type": "t3.medium",
                            "desired_capacity": 2,
                        }
                    ],
                },
            }
        }

        deployment = KubernetesDeployment(
            stack_name=stack_name,
            provider=provider,
            region=region,
            deployment_config=deployment_config,
        )

        # Assert that a FileNotFoundError is raised when the specified provider is not supported
        with pytest.raises(FileNotFoundError):
            deployment.generate_required_provider_config()
