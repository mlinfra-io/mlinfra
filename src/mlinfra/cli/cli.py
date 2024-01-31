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

import tasks
from invoke import Collection, Program
from mlinfra.utils.constants import VERSION

namespace = Collection()
namespace.add_task(tasks.terraform)
namespace.add_task(tasks.estimate_cost)
namespace.add_task(tasks.generate_terraform_config)

program = Program(version=VERSION, namespace=namespace, name="mlinfra")


def cli() -> None:
    """Welcome to mlinfra cli! Deploy any MLOps tooling at the click of a button.

    Github: https://github.com/mlinfra-io/mlinfra
    Documentation: https://mlinfra.io/
    """
    program.run()


if __name__ == "__main__":
    program.cli()
