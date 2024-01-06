from enum import Enum


class CloudProvider(Enum):
    """
    All providers under one class
    """

    AWS = "aws"
    GCP = "gcp"
    AZURE = "azure"
    # ORACLE = "oracle"
