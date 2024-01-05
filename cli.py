import tasks as tasks
from invoke import Collection, Program

namespace = Collection()
namespace.add_task(tasks.terraform)
namespace.add_task(tasks.estimate_cost)
namespace.add_task(tasks.generate_terraform_config)

program = Program(version="0.0.1", namespace=namespace, name="platinfra")


def main() -> None:
    program.run()


# if __name__ == "__main__":
#     program.run()
