from enum import Enum


class DeploymentType(Enum):
    CLOUD_NATIVE = "cloud_native"
    CLOUD_INFRA = "cloud_infra"
    KUBERNETES = "kubernetes"
