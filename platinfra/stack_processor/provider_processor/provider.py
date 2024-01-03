from abc import ABC, abstractmethod

import yaml


class AbstractProvider(ABC):
    """
    Abstract class for providers
    """

    @abstractmethod
    def __init__(self, stack_name: str, config: yaml):
        self.stack_name = stack_name
        self.config = config

    @abstractmethod
    def configure_provider(self):
        pass
