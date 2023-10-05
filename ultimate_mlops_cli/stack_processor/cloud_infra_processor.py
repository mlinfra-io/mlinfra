import logger
from .base_processor import BaseProcessor


class CloudInfraProcessor(BaseProcessor):
    def __init__(self, config):
        super(CloudInfraProcessor, self).__init__(config)

    def process(self):
        logger.info("Processing Cloud Infrastructure")
