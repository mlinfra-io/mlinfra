import logger
from ultimate_mlops_cli.stack_processor.base_processor import BaseProcessor


class CloudInfraProcessor(BaseProcessor):
    def __init__(self, config):
        super(CloudInfraProcessor, self).__init__(config)

    def generate(self):
        logger.info("Processing Cloud Infrastructure")
