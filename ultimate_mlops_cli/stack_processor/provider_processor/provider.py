import yaml
from abc import ABC, abstractmethod


class AbstractProvider(ABC):
    """
    Abstract class for providers
    """

    @abstractmethod
    def __init__(self, stack_name: str, config: yaml):
        self.stack_name = stack_name
        self.config = config

        self.account_id = config.get("account_id", None)
        self.region = config.get("region", None)
        self.access_key = config.get("access_key", None)
        self.secret_key = config.get("secret_key", None)
        self.role_arn = config.get("role_arn", None)

    @abstractmethod
    def get_provider_details(self) -> (str, str):
        pass

    @abstractmethod
    def get_access_credentials(self) -> (str, str):
        pass

    @abstractmethod
    def configure_provider(self):
        pass
