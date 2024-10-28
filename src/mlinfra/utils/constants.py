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

from importlib.metadata import version
from time import time
from typing import Final

# TODO: update this to path.cwd
TF_PATH = "./.mlinfra_stack"
# This folder is created outside TF_PATH so that its not deleted when the
# user checks state again
TF_LOCAL_STATE_PATH = "../.mlinfra_local_state"

CREATE_VPC_DB_SUBNET = ["remote_tracking"]

DEV_VERSION: Final = "dev"
MLINFRA_DISABLE_REPORTING: Final = "MLINFRA_DISABLE_REPORTING"
SESSION_ID: Final = int(time() * 1000)

VERSION: Final = version("mlinfra")

EXECUTABLE_PATH = "/usr/local/bin"

ENABLE_RICH_TRACEBACK = True
