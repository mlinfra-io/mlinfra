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


@app.command("plan", help="Plan the terraform stack config")
def plan(
    stack_config_path: Annotated[
        str, typer.Option("--config-file", help="Path to the stack configuration file")
    ],
    # args: Annotated[List[str], typer.Argument(help="Additional arguments to pass")],
):
    """
    Plan the terraform stack config.

    Args:
        stack_config_path (str): Path to the stack configuration file.
        args (List[str]): Additional arguments to pass to the terraform plan command.
    """
    targets_list = Terraform(stack_config_path=stack_config_path).plan()
    targets_list = ""

    run_command(["terraform", f"-chdir={TF_PATH}", "init"], capture_output=False)
    args = ["-lock=false", "-input=false", "-compact-warnings"]
    # args.append(targets_list)
    amplitude_client.send_event(
        amplitude_client.PLAN_EVENT,
        event_properties={"modules": targets_list},
    )
    run_command(
        ["terraform", f"-chdir={TF_PATH}", "plan"] + args + ["-out", "tfplan.binary"],
        capture_output=False,
    )


@app.command("apply", help="Apply the terraform stack config")
def apply(
    stack_config_path: Annotated[
        str, typer.Option("--config-file", help="Path to the stack configuration file")
    ],
    # args: Annotated[List[str], typer.Argument(help="Additional arguments to pass")],  # = ["-lock=false", "-input=false", "-compact-warnings"],
):
    """
    Apply the terraform stack config.

    Args:
        stack_config_path (str): Path to the stack configuration file.
        args (List[str]): Additional arguments to pass to the terraform apply command.
    """
    targets_list = Terraform(stack_config_path=stack_config_path).plan()
    targets_list = ""

    run_command(["terraform", f"-chdir={TF_PATH}", "init"], capture_output=False)
    args = ["-lock=false", "-input=false", "-compact-warnings"]
    # args.append(targets_list)
    amplitude_client.send_event(
        amplitude_client.APPLY_EVENT,
        event_properties={"modules": targets_list},
    )
    run_command(
        ["terraform", f"-chdir={TF_PATH}", "plan"] + args + ["-out", "tfplan.binary"],
        capture_output=False,
    )
    run_command(
        ["terraform", f"-chdir={TF_PATH}", "apply", "-auto-approve", "tfplan.binary"],
        capture_output=False,
    )


@app.command("destroy", help="Tear down the deployed terraform stack")
def destroy(
    stack_config_path: Annotated[
        str, typer.Option("--config-file", help="Path to the stack configuration file")
    ],
    # args: Annotated[List[str], typer.Argument(help="Additional arguments to pass")],
):
    """
    Run terraform for the config file with the given action and args.
    """
    targets_list = Terraform(stack_config_path=stack_config_path).plan()
    targets_list = ""

    run_command(["terraform", f"-chdir={TF_PATH}", "init"], capture_output=False)
    args = ["-auto-approve"]
    # args.append(targets_list)
    amplitude_client.send_event(
        amplitude_client.DESTROY_EVENT,
        event_properties={"modules": targets_list},
    )
    run_command(["terraform", f"-chdir={TF_PATH}", "destroy"] + args, capture_output=False)

    # elif action == "force-unlock":
    #     file_processor.force_unlock()
    #     action = f"plan {args} -lock=false"
