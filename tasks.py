from invoke import task
from ultimate_mlops_cli.utils.constants import TF_PATH
from ultimate_mlops_cli.utils.utils import clean_tf_directory
from ultimate_mlops_cli.stack_file_processor import StackfileProcessor
from ultimate_mlops_cli.terraform.terraform_state_helper import TerraformStateHelper


@task(
    pre=[],
    help={
        "stack_config_path": "Path of the config file",
    },
)
def estimate_cost(
    ctx,
    stack_config_path: str,
    args: str = "",
):
    # clean the tf directory before init
    clean_tf_directory()

    file_processor = StackfileProcessor(stack_config_path=stack_config_path)

    state_helper = TerraformStateHelper(
        state=file_processor.get_state_file_name(), region=file_processor.get_region()
    )
    state_helper.manage_aws_state_storage()

    file_processor.generate()

    ctx.run(f"cd {TF_PATH} && terraform init")
    ctx.run(
        f"cd {TF_PATH} && terraform plan -lock=false -out tfplan.binary && terraform show -json tfplan.binary > plan.json"
    )
    ctx.run(f"infracost diff --show-skipped --no-cache --path {TF_PATH}/plan.json")


@task(
    pre=[],
    help={
        "stack_config_path": "Path of the config file",
        "action": "Allowed actions are plan, destroy, apply, force-unlock",
    },
)
def terraform(
    ctx,
    stack_config_path: str,
    action: str = "plan",
    args: str = "",
):
    # clean the tf directory before init
    clean_tf_directory()

    file_processor = StackfileProcessor(stack_config_path=stack_config_path)

    state_helper = TerraformStateHelper(
        state=file_processor.get_state_file_name(), region=file_processor.get_region()
    )
    state_helper.manage_aws_state_storage()

    file_processor.generate()

    ctx.run(f"cd {TF_PATH} && terraform init")

    if action in ["apply", "destroy"]:
        action += " -auto-approve"
    # elif action == "force-unlock":
    #     file_processor.force_unlock()
    #     action = f"plan {args} -lock=false"
    elif action == "plan":
        action += " -lock=false"

    ctx.run(f"cd {TF_PATH} && terraform {action} {args}")
