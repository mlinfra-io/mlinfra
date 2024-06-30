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

from enum import Enum


class DeploymentType(Enum):
    """
    Enumeration that represents different types of deployments.
    """

    # managed cloud providers
    CLOUD_NATIVE = "cloud_native"
    CLOUD_VM = "cloud_vm"
    KUBERNETES = "kubernetes"

    # local providers
    KIND = "kind"
    K3S = "k3s"
    MINIKUBE = "minikube"
    MICROK8S = "microk8s"
    DOCKER_COMPOSE = "docker_compose"
    DOCKER = "docker"
