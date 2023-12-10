from invoke import task
from platinfra_cli.utils.constants import TF_PATH
from platinfra_cli.utils.utils import clean_tf_directory
from platinfra_cli.stack_processor.stack_generator import (
    StackGenerator,
)
from platinfra_cli.terraform.terraform_state_helper import TerraformStateHelper


def run_initial_terraform_tasks(
    stack_config_path: str,
):
    # clean the tf directory before init
    clean_tf_directory()

    # TODO: UPDATE LOGIC for generating state file
    file_processor = StackGenerator(stack_config_path=stack_config_path)

    state_helper = TerraformStateHelper(
        state=file_processor.get_state_file_name(), region=file_processor.get_region()
    )
    state_helper.manage_aws_state_storage()

    file_processor.generate()


@task(
    pre=[],
    help={
        "stack_config_path": "Path of the config file",
    },
)
def estimate_cost(
    ctx,
    stack_config_path: str,
):
    """
    Estimate cost of the contents of config file
    """
    run_initial_terraform_tasks(stack_config_path=stack_config_path)

    ctx.run(f"terraform -chdir={TF_PATH} init")
    ctx.run(
        f"terraform -chdir={TF_PATH} plan -no-color -lock=false -input=false -compact-warnings -out tfplan.binary"
    )
    ctx.run(
        f"terraform -chdir={TF_PATH} show -no-color -json tfplan.binary > {TF_PATH}/plan.json"
    )
    ctx.run(f"infracost diff --show-skipped --no-cache --path {TF_PATH}/plan.json")


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
):
    """
    Run terraform for the config file with the given action and args.
    """
    run_initial_terraform_tasks(stack_config_path=stack_config_path)

    ctx.run(f"terraform -chdir={TF_PATH} init")

    if action in ["apply", "destroy"]:
        action += " -auto-approve"
    # elif action == "force-unlock":
    #     file_processor.force_unlock()
    #     action = f"plan {args} -lock=false"
    elif action == "plan":
        action += " -lock=false -input=false -compact-warnings"

    ctx.run(f"terraform -chdir={TF_PATH} {action} {args}")
