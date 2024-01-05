from invoke import task
from platinfra.terraform.terraform import Terraform
from platinfra.utils.constants import TF_PATH


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
    Terraform(stack_config_path).plan()
    ctx.run(f"terraform -chdir={TF_PATH} init")
    print(
        f"""
            Terraform config has been generated in the {TF_PATH} folder.
        """
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
) -> None:
    """
    Run terraform for the config file with the given action and args.
    """
    targets_list = Terraform(stack_config_path=stack_config_path).apply()
    print(targets_list)

    ctx.run(f"terraform -chdir={TF_PATH} init")

    if action in ["apply", "destroy"]:
        action += " -auto-approve"
    # elif action == "force-unlock":
    #     file_processor.force_unlock()
    #     action = f"plan {args} -lock=false"
    elif action == "plan":
        action += " -lock=false -input=false -compact-warnings"

    # print(f"terraform -chdir={TF_PATH} {action} {args}")
    ctx.run(f"terraform -chdir={TF_PATH} {action} {args}")
