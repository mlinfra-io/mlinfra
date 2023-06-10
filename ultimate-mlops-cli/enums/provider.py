from enum import Enum


class Provider(Enum):
    """
    All providers under one class
    """

    AWS = "aws"
    GCP = "gcp"
    KUBERNETES = "kubernetes"
