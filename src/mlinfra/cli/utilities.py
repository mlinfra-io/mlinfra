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

import typer
from mlinfra.amplitude import amplitude_client
from mlinfra.terraform.terraform import Terraform
from mlinfra.utils.constants import TF_PATH
from mlinfra.utils.utils import run_command
from typing_extensions import Annotated

app = typer.Typer()


@app.command(
    "generate-terraform-config", help=f"Generates the terraform config in the {TF_PATH} folder path"
)
def generate_terraform_config(
    stack_config_path: Annotated[
        str, typer.Option("--config-file", help="Path to the stack configuration file")
    ],
):
    f"""
    Generates the terraform config in the {TF_PATH} folder path

    Args:
        stack_config_path (str): Path to the stack configuration file.
    """
    modules = Terraform(stack_config_path).plan()
    current_properties = {"modules": modules}

    amplitude_client.send_event(
        amplitude_client.START_GEN_TERRAFORM_EVENT,
        event_properties=current_properties,
    )

    run_command(["terraform", f"-chdir={TF_PATH}", "init"], capture_output=False)
    print(
        f"""
            Terraform config has been generated in the {TF_PATH} folder.
        """
    )
    amplitude_client.send_event(
        amplitude_client.FINISH_GEN_TERRAFORM_EVENT,
        event_properties=current_properties,
    )


@app.command("estimate-cost", help="Estimate the cost of your stack config")
def estimate_cost(
    stack_config_path: Annotated[
        str, typer.Option("--config-file", help="Path to the stack configuration file")
    ],
):
    """
    Estimate cost of the contents of the config file.

    Args:
        stack_config_path (str): Path to the stack configuration file.
    """
    Terraform(stack_config_path).plan()

    run_command(["terraform", f"-chdir={TF_PATH}", "init"], capture_output=False)

    run_command(
        [
            "terraform",
            f"-chdir={TF_PATH}",
            "plan",
            "-no-color",
            "-lock=false",
            "-input=false",
            "-compact-warnings",
            "-out",
            "tfplan.binary",
        ],
        capture_output=False,
    )

    run_command(
        [
            "sh",
            "-c",
            f"terraform -chdir={TF_PATH} show -no-color -json tfplan.binary > {TF_PATH}/plan.json",
        ],
        capture_output=False,
    )

    run_command(
        ["infracost", "diff", "--show-skipped", "--no-cache", "--path", f"{TF_PATH}/plan.json"],
        capture_output=False,
    )
    amplitude_client.send_event(
        amplitude_client.COST_ESTIMATOR_EVENT,
        event_properties={},
    )
