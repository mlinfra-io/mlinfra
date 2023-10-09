from abc import ABC, abstractmethod


class AbstractProvider(ABC):
    @abstractmethod
    def get_provider_details(self):
        pass
