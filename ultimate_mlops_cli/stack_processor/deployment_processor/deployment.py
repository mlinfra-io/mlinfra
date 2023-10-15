import json
from abc import ABC, abstractmethod
from ultimate_mlops_cli.enums.provider import Provider


class AbstractDeployment(ABC):
    """
    Abstract class for deployment
    """

    def __init__(self, stack_name: str, provider: Provider, region: str):
        self.stack_name = stack_name
        self.provider = provider
        self.region = region

    @abstractmethod
    def configure_deployment(self):
        pass

    def get_provider_backend(self, provider: Provider) -> json:
        if provider == Provider.AWS:
            return {
                "backend": {
                    "s3": {
                        "bucket": self.stack_name,
                        "key": "ultimate-mlops-stack",
                        "dynamodb_table": self.stack_name,
                        "region": self.region,
                        "encrypt": True,
                    }
                }
            }
        # Add other providers here
        # return {}
