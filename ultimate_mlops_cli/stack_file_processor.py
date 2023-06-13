import json
import os
import yaml

from .enums.provider import Provider
from .enums.deployment_type import DeploymentType

from .utils.constants import TF_PATH
from .utils.utils import clean_tf_directory
from .terraform.terraform_state_helper import TerraformStateHelper


class StackfileProcessor:
    def __init__(self, stack_config_path):
        self.stack = stack_config_path
        self.stack_name = ""
        self.account_id = ""
        self.provider = "aws"
        self.deployment_type = ""
        self.state_file_name = ""
        self.is_stack_component = True
        self.stack_config = self.init_stack_config()
        self.output = {"output": []}

    def get_state_file_name(self):
        return self.state_file_name

    def get_region(self):
        return self.region

    def init_stack_config(self):
        clean_tf_directory()

        os.makedirs(TF_PATH, mode=0o777)
        with open(self.stack, "r") as stack_config:
            config = yaml.safe_load(stack_config.read())
            self.stack_name = config["name"]
            if "provider" in config:
                self.is_stack_component = False
                self.provider = Provider(config["provider"]["name"])
                self.account_id = config["provider"]["account_id"]
                self.region = config["provider"]["region"]
                self.deployment_type = DeploymentType(
                    config["provider"]["deployment_type"]
                )
                self.state_file_name = f"tfstate-{self.stack_name}-{self.region}"
            return config

    def prepare_common_configuration(self):
        contains_kubernetes = False
        for stack in self.stack_config["stacks"]:
            if "orchestrator" in stack and (
                stack["orchestrator"] == "k8s" or stack["orchestrator"] == "kubernetes"
            ):
                contains_kubernetes = True

        with open("modules/cloud/aws/data.tf.json", "r") as data_json:
            with open(f"./{TF_PATH}/data.tf.json", "w", encoding="utf-8") as tf_json:
                json_data = json.load(data_json)

                if contains_kubernetes:
                    json_data["data"]["aws_eks_cluster_auth"] = {
                        "k8s": {
                            "name": "${data.terraform_remote_state.parent.outputs.k8s_cluster_name}"
                        }
                    }
                    json_data["data"]["terraform_remote_state"] = {
                        "parent": {
                            "backend": "s3",
                            "config": {
                                "bucket": self.state_file_name,
                                "key": "ultimate-mlops-stack",
                                "dynamodb_table": self.state_file_name,
                                "region": self.region,
                            },
                        }
                    }
                json.dump(json_data, tf_json, ensure_ascii=False, indent=2)

        with open("modules/cloud/aws/provider.tf.json", "r") as data_json:
            with open(
                f"./{TF_PATH}/provider.tf.json", "w", encoding="utf-8"
            ) as tf_json:
                data = json.load(data_json)
                data["provider"]["aws"]["region"] = self.region
                data["provider"]["aws"]["allowed_account_ids"] = [self.account_id]
                data["provider"]["aws"]["default_tags"]["tags"][
                    "deployment_type"
                ] = self.deployment_type.value
                data["provider"]["aws"]["default_tags"]["tags"]["region"] = self.region
                data["provider"]["aws"]["default_tags"]["tags"]["stack"] = self.stack

                if contains_kubernetes:
                    data["provider"]["helm"]["kubernetes"][
                        "host"
                    ] = "${data.terraform_remote_state.parent.outputs.k8s_endpoint}"
                    data["provider"]["helm"]["kubernetes"][
                        "cluster_ca_certificate"
                    ] = "${base64decode(data.terraform_remote_state.parent.outputs.k8s_ca_data)}"
                json.dump(data, tf_json, ensure_ascii=False, indent=2)

        with open("modules/cloud/aws/terraform.tf.json", "r") as data_json:
            with open(
                f"./{TF_PATH}/terraform.tf.json", "w", encoding="utf-8"
            ) as tf_json:
                data = json.load(data_json)

                if contains_kubernetes:
                    print("Add helm and kubernetes provider")

                # data["terraform"].update(
                #     {
                #         "backend": {
                #             "s3": {
                #                 "bucket": self.state,
                #                 "key": "ultimate-mlops-stack",
                #                 "dynamodb_table": self.state,
                #                 "region": self.region,
                #             }
                #         }
                #     }
                # )
                json.dump(data, tf_json, ensure_ascii=False, indent=2)

    def _read_config_file(
        self, stack_type: str, application_name: str, extension: str = "yaml"
    ) -> json:
        with open(
            f"modules/applications/{stack_type}/{application_name}/{application_name}_{self.deployment_type.value}.{extension}",
            "r",
            encoding="utf-8",
        ) as tf_config:
            if extension == "yaml":
                return yaml.safe_load(tf_config.read())
            return json.loads(tf_config.read())

    def prepare_stack_modules(self):
        # inject vpc module
        if self.provider == Provider.AWS:
            name = "vpc"
            json_module = {"module": {name: {}}}
            json_module["module"][name]["name"] = f"{self.stack_name}-vpc"
            json_module["module"][name]["source"] = f"../modules/cloud/aws/{name}"

            with open(f"./{TF_PATH}/{name}.tf.json", "w", encoding="utf-8") as tf_json:
                json.dump(json_module, tf_json, ensure_ascii=False, indent=2)
        elif self.provider == Provider.GCP:
            pass

        for module in self.stack_config["stacks"]:
            stack_type = [key for key in module.keys()][0]

            if "name" in module[stack_type]:
                name = module[stack_type]["name"]
            else:
                raise KeyError(f"No application assigned to the stack: {stack_type}")

            json_module = {"module": {name: {}}}

            # TODO: pickup right module source based on the deployment type

            json_module["module"][name][
                "source"
            ] = f"../modules/applications/{stack_type}/{name}/tf_module"

            # TODO: stitch together the inputs from vpc or other deployment type
            # stack
            json_module["module"][name].update(
                {
                    "vpc_id": "${module.vpc.vpc_id}",
                    "subnet_id": "${module.vpc.subnet_id[0]}",
                    "default_vpc_sg": "${module.vpc.default_vpc_sg}",
                    "vpc_cidr_block": "${module.vpc.vpc_cidr_block}",
                    "db_subnet_group_name": "${module.vpc.database_subnet_group}",
                }
            )

            application_config = self._read_config_file(
                stack_type=stack_type, application_name=name
            )
            if application_config is not None and "outputs" in application_config:
                for output in application_config["outputs"]:
                    if output["export"]:
                        output_val = "${ %s }" % f"module.{name}.{output['name']}"

                        self.output["output"].append(
                            {output["name"]: {"value": output_val}}
                        )

            # fetching json schema from module and adding the missing variables
            # to the module definition before applying terraform plan
            # module_json_schema = self._read_config_data(
            #     module_name=module_name, extension="json"
            # )
            # if module_json_schema is not None and "message" not in module_json_schema:
            #     if "properties" in module_json_schema:
            #         for item in module_json_schema["properties"]:
            #             if (
            #                 item not in json_module["module"][name]
            #                 and "enum" not in module_json_schema["properties"][item]
            #             ):
            #                 json_module["module"][name][item] = module_json_schema[
            #                     "properties"
            #                 ][item].get("default")

            with open(
                f"./{TF_PATH}/stack_{stack_type}.tf.json", "w", encoding="utf-8"
            ) as tf_json:
                json.dump(json_module, tf_json, ensure_ascii=False, indent=2)

    def get_eks_module_refs(self, k8s_module_name: str = None) -> dict:
        module_source = (
            f"module.{k8s_module_name}"
            if k8s_module_name is not None and len(k8s_module_name) != 0
            else "data.terraform_remote_state.parent.outputs"
        )
        if self.provider == "aws":
            return {
                "host": f"${{{module_source}.k8s_endpoint}}",
                "token": "${data.aws_eks_cluster_auth.k8s.token}",
                "cluster_ca_certificate": f"${{base64decode({module_source}.k8s_ca_data)}}",
            }

    def _get_k8s_module_name(self, return_key: str = "cluster_name") -> str:
        k8s_module = [
            _module
            for _module in self.stack_config["modules"]
            if _module["type"] == "eks"
        ]
        k8s_module_name = k8s_module[0][return_key] if len(k8s_module) != 0 else None
        return k8s_module_name

    def prepare_stack_outputs(self):
        self.output["output"].append({"state_storage": {"value": self.state_file_name}})
        self.output["output"].append(
            {
                "providers": {
                    "value": {
                        "aws": {
                            "region": self.region,
                            "account_id": self.account_id,
                        }
                    }
                }
            }
        )
        with open(f"./{TF_PATH}/output.tf.json", "w", encoding="utf-8") as tf_json:
            json.dump(self.output, tf_json, ensure_ascii=False, indent=2)

    def _common_service_input(self) -> any:
        return {
            "variable": [
                {"region": [{"type": "string", "default": self.region}]},
                {"account_id": [{"type": "string", "default": self.account_id}]},
            ]
        }

    def _user_input(self) -> any:
        user_input = []
        for v in self.stack_config["input_variables"]:
            input = {v["name"]: [{"type": "string"}]}
            if "default" in v:
                input[v["name"]][0]["default"] = v["default"]
            user_input.append(input)
        return user_input

    def _default_config_input(self) -> any:
        user_input = []
        if "environments" in self.stack_config:
            for env in self.stack_config["environments"]:
                if self._is_env_match(env["name"]):
                    if "variables" in env:
                        for k in env["variables"]:
                            user_input.append(
                                {
                                    k: [
                                        {
                                            "type": "string",
                                            "default": env["variables"][k],
                                        }
                                    ]
                                }
                            )
                    break
        return user_input

    def prepare_input(self):
        if "input_variables" in self.stack_config:
            json_output = {"variable": []}
            if self.is_stack_component:
                json_output = self._common_service_input()

            json_output["variable"].extend(self._user_input())
            json_output["variable"].extend(self._default_config_input())

            with open(
                f"./{TF_PATH}/variable.tf.json", "w", encoding="utf-8"
            ) as tf_json:
                json.dump(json_output, tf_json, ensure_ascii=False, indent=2)

    def generate(self):
        self.prepare_common_configuration()
        self.prepare_stack_modules()
        self.prepare_stack_outputs()
        # self.prepare_input()


if __name__ == "__main__":
    tf = StackfileProcessor(stack_config_path="examples/aws-mlflow.yaml")
    state_helper = TerraformStateHelper(
        state=tf.get_state_file_name(), region=tf.get_region()
    )
    state_helper.manage_aws_state_storage()
    tf.generate()
