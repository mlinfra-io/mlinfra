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

from invoke import task
from mlinfra.amplitude import amplitude_client
from mlinfra.terraform.terraform import Terraform
from mlinfra.utils.constants import TF_PATH


@task(
    pre=[],
    help={
        "stack_config_path": "Path of the config file",
    },
)
def generate_terraform_config(
    ctx,
    stack_config_path: str,
) -> None:
    f"""
    Generates the terraform config in the {TF_PATH} folder path
    """
    modules = Terraform(stack_config_path).plan()
    current_properties = {"modules": modules}

    amplitude_client.send_event(
        amplitude_client.START_GEN_TERRAFORM_EVENT,
        event_properties=current_properties,
    )
    ctx.run(f"terraform -chdir={TF_PATH} init")
    print(
        f"""
            Terraform config has been generated in the {TF_PATH} folder.
        """
    )
    amplitude_client.send_event(
        amplitude_client.END_GEN_TERRAFORM_EVENT,
        event_properties=current_properties,
    )


@task(
    pre=[],
    help={
        "stack_config_path": "Path of the config file",
    },
)
def estimate_cost(
    ctx,
    stack_config_path: str,
) -> None:
    """
    Estimate cost of the contents of config file
    """
    Terraform(stack_config_path).plan()

    ctx.run(f"terraform -chdir={TF_PATH} init")
    ctx.run(
        f"terraform -chdir={TF_PATH} plan -no-color -lock=false -input=false -compact-warnings -out tfplan.binary"
    )
    ctx.run(f"terraform -chdir={TF_PATH} show -no-color -json tfplan.binary > {TF_PATH}/plan.json")
    ctx.run(f"infracost diff --show-skipped --no-cache --path {TF_PATH}/plan.json")
    amplitude_client.send_event(
        amplitude_client.COST_ESTIMATOR_EVENT,
        event_properties={},
    )


@task(
    pre=[],
    help={
        "stack_config_path": "Path of the config file",
        "action": "Allowed actions are plan, destroy, apply, force-unlock (not yet available). Defaults to plan",
        "args": "Additional args to pass to terraform. Defaults to none",
    },
)
def terraform(
    ctx,
    stack_config_path: str,
    action: str = "plan",
    args: str = "",
) -> None:
    """
    Run terraform for the config file with the given action and args.
    """
    targets_list = Terraform(stack_config_path=stack_config_path).plan()
    targets_list = ""

    ctx.run(f"terraform -chdir={TF_PATH} init")

    if action == "plan":
        args += f"{targets_list} -lock=false -input=false -compact-warnings"
        amplitude_client.send_event(
            amplitude_client.PLAN_EVENT,
            event_properties={},
        )
        ctx.run(f"terraform -chdir={TF_PATH} plan {args} -out tfplan.binary")
    elif action == "apply":
        args += f"{targets_list} -lock=false -input=false -compact-warnings"
        amplitude_client.send_event(
            amplitude_client.APPLY_EVENT,
            event_properties={},
        )
        ctx.run(f"terraform -chdir={TF_PATH} plan {args} -out tfplan.binary")
        ctx.run(f"terraform -chdir={TF_PATH} apply -auto-approve tfplan.binary")
    elif action == "destroy":
        args = "-auto-approve"
        amplitude_client.send_event(
            amplitude_client.DESTROY_EVENT,
            event_properties={},
        )
        ctx.run(f"terraform -chdir={TF_PATH} destroy {args}")
    # elif action == "force-unlock":
    #     file_processor.force_unlock()
    #     action = f"plan {args} -lock=false"
