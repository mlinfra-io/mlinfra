import yaml
from ultimate_mlops_cli.stack_processor.provider_processor.provider import (
    AbstractProvider,
)


class AWSProvider(AbstractProvider):
    def __init__(self, config: yaml):
        self.config = config
        self.account_id = config.get("account_id", None)
        self.region = config.get("region", None)
        self.access_key = config.get("access_key", None)
        self.secret_key = config.get("secret_key", None)
        self.role_arn = config.get("role_arn", None)

    def get_provider_details(self) -> (str, str):
        super().get_provider_details()
        return (self.account_id, self.region)

    def get_access_credentials(self) -> (str, str):
        return (self.access_key, self.secret_key)

    def get_role_arn(self) -> str:
        return self.role_arn
