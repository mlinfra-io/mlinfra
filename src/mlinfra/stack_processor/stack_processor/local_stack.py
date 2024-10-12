#     Copyright (c) mlinfra 2024. All Rights Reserved.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at:
#         https://www.apache.org/licenses/LICENSE-2.0
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#     or implied. See the License for the specific language governing
#     permissions and limitations under the License.

import json

import yaml
from mlinfra.enums.cloud_provider import CloudProvider
from mlinfra.enums.deployment_type import DeploymentType
from mlinfra.stack_processor.stack_processor.stack import (
    AbstractStack,
)
from mlinfra.utils.constants import TF_PATH


class LocalStack(AbstractStack):
    """
    The LocalStack class is responsible for generating the
    Terraform configuration files for the KinD stack.
    """

    def __init__(
        self,
        state_file_name: str,
        region: str,
        account_id: str,
        provider: CloudProvider,
        deployment_type: DeploymentType,
        stacks: yaml,
    ):
        """
        Constructor for the LocalStack class.

        :param provider: The cloud provider
        :type provider: Provider
        :param stacks: The stacks configuration
        :type stacks: yaml
        """
        super().__init__(
            state_file_name=state_file_name,
            region=region,
            account_id=account_id,
            provider=provider,
            deployment_type=deployment_type,
            stacks=stacks,
        )
        self.output = {"output": []}

    def process_stack_config(self):
        pass

    def process_stack_modules(self):
        if self.stacks:
            for module in self.stacks:
                # extracting stack type
                stack_type = [key for key in module.keys()][0]

                if "name" in module[stack_type]:
                    name = module[stack_type]["name"]
                else:
                    raise KeyError(f"No application assigned to the stack: {stack_type}")

                json_module = {"module": {name: {}}}

                # TODO: pickup right module source based on the deployment type

                json_module["module"][name]["source"] = (
                    f"./modules/applications/{self.provider.value}/{stack_type}/{name}/tf_module"
                )

                # Reading inputs and outputs from the config file
                # placed in the applications/application folder and
                # adding them to json config for the application module
                application_config = self._read_config_file(
                    stack_type=stack_type, application_name=name
                )

                if application_config is not None:
                    if "inputs" in application_config and application_config["inputs"]:
                        inputs = {}
                        for input in application_config["inputs"]:
                            if not input["user_facing"]:
                                input_name = input["name"]
                                # handle the input from the yaml config
                                # if the input value is not a string
                                input_value = (
                                    input["default"]
                                    if input["default"] != "None"
                                    else "${ %s }" % f"{input['value']}"
                                )
                                inputs.update({input_name: input_value})
                            json_module["module"][name].update(inputs)

                    if "outputs" in application_config and application_config["outputs"]:
                        for output in application_config["outputs"]:
                            if output["export"]:
                                output_val = "${ %s }" % f"module.{name}.{output['name']}"

                                self.output["output"].append(
                                    {output["name"]: {"value": output_val}}
                                )

                # Checks if there are params in the config file which can be
                # passed to the application module. Params are checked against
                # the application module yaml file
                if "params" in module[stack_type]:
                    # TODO: throw error for a param not existing in the yaml config
                    params = {}
                    for key, value in module[stack_type]["params"].items():
                        for input in application_config["inputs"]:
                            if key == input["name"]:
                                if input["user_facing"]:
                                    params.update({key: value})
                                else:
                                    raise KeyError(f"{key} is not a user facing parameter")
                    json_module["module"][name].update(params)

                json_module["module"][name].update(
                    {"depends_on": [f"module.{self.deployment_type.value}"]}
                )

                with open(
                    f"./{TF_PATH}/stack_{stack_type}.tf.json", "w", encoding="utf-8"
                ) as tf_json:
                    json.dump(json_module, tf_json, ensure_ascii=False, indent=2)
        else:
            print(
                """
                  No stacks found in the configuration file.
                  Please check the documentation for more information.
                """
            )
            # TODO: think about throwing an exception here
            # raise Exception("No stacks found in the configuration file")

    def process_stack_outputs(self):
        with open(f"./{TF_PATH}/output.tf.json", "w", encoding="utf-8") as tf_json:
            json.dump(self.output, tf_json, ensure_ascii=False, indent=2)

    def process_stack_inputs(self):
        pass

    def generate(self):
        # logger.info("Processing Kubernetes Infrastructure")
        self.process_stack_config()
        self.process_stack_inputs()
        self.process_stack_modules()
        self.process_stack_outputs()


if __name__ == "__main__":
    pass
