import tasks
from invoke import Collection, Program

namespace = Collection()
namespace.add_task(tasks.terraform)
namespace.add_task(tasks.estimate_cost)
namespace.add_task(tasks.generate_terraform_config)

program = Program(version="0.0.1", namespace=namespace, name="platinfra")


def cli() -> None:
    """Welcome to platinfra cli! Deploy any MLOps tooling at the click of a button.

    Github: https://github.com/platinfra/platinfra
    Documentation: https://platinfra.github.io/
    """
    program.run()


if __name__ == "__main__":
    program.cli()
