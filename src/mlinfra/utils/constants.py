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

from time import time
from typing import Final

import toml

# TODO: update this to path.cwd
TF_PATH = "./.mlops_stack"

CREATE_VPC_DB_SUBNET = ["remote_tracking"]

DEV_VERSION: Final = "dev"
MLINFRA_DISABLE_REPORTING: Final = "MLINFRA_DISABLE_REPORTING"
SESSION_ID: Final = int(time() * 1000)

with open("../pyproject.toml", "r") as pyproject_toml_file:
    pyproj_toml_data = toml.load(pyproject_toml_file)
VERSION: Final = pyproj_toml_data["project"]["version"]
