import logger
from ultimate_mlops_cli.stack_processor.base_processor import BaseProcessor


class KubernetesProcessor(BaseProcessor):
    def __init__(self, config):
        super(KubernetesProcessor, self).__init__(config)

    def process(self):
        logger.info("Processing Kubernetes Infrastructure")
