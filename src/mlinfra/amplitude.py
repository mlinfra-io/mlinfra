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

import os
import platform
import random
import string
import sys
from typing import Optional

from getmac import get_mac_address
from git.config import GitConfigParser
from mlinfra.utils.constants import (
    DEV_VERSION,
    MLINFRA_DISABLE_REPORTING,
    SESSION_ID,
    VERSION,
)
from mlinfra.utils.utils import safe_run
from requests import codes, post


class AmplitudeClient:
    PLAN_EVENT = "PLAN"
    APPLY_EVENT = "APPLY"
    DESTROY_EVENT = "DESTROY"
    COST_ESTIMATOR_EVENT = "COST_ESTIMATOR_EVENT"
    START_GEN_TERRAFORM_EVENT = "START_GEN_TERRAFORM"
    FINISH_GEN_TERRAFORM_EVENT = "FINISH_GEN_TERRAFORM"
    VALID_EVENTS = [
        APPLY_EVENT,
        PLAN_EVENT,
        DESTROY_EVENT,
        COST_ESTIMATOR_EVENT,
        START_GEN_TERRAFORM_EVENT,
        FINISH_GEN_TERRAFORM_EVENT,
    ]

    def __init__(self) -> None:
        self.api_key = "167aefed6bd10a9200b052a52504ff5"
        self.user_id = GitConfigParser().get_value("user", "email", "no_user")
        self.device_id = get_mac_address()
        self.os_name = os.name
        self.platform = platform.system()
        self.os_version = platform.version()

    @safe_run
    def send_event(
        self,
        event_type: str,
        event_properties: Optional[dict] = None,
        user_properties: Optional[dict] = None,
    ) -> None:
        if hasattr(sys, "_called_from_test") or VERSION == DEV_VERSION:
            print("Not sending amplitude cause we think we're in a pytest or in dev")
            return
        event_properties = event_properties or {}
        user_properties = user_properties or {}
        insert_id = "".join(
            random.SystemRandom().choices(string.ascii_letters + string.digits, k=16)
        )
        if event_type not in self.VALID_EVENTS:
            raise Exception(f"Invalid event type: {event_type}")
        body = {
            "api_key": self.api_key,
            "events": [
                {
                    "user_id": self.user_id,
                    "device_id": self.device_id,
                    "event_type": event_type,
                    "event_properties": event_properties,
                    "user_properties": user_properties,
                    "app_version": VERSION,
                    "platform": self.platform,
                    "os_name": self.os_name,
                    "os_version": self.os_version,
                    "insert_id": insert_id,
                    "session_id": SESSION_ID,
                }
            ],
        }
        headers = {"Content-Type": "application/json", "Accept": "*/*"}

        if os.environ.get(MLINFRA_DISABLE_REPORTING) is None:
            try:
                r = post(
                    "https://api2.amplitude.com/2/httpapi",
                    params={},
                    headers=headers,
                    json=body,
                    timeout=10,
                )
                if r.status_code != codes.ok:
                    raise Exception(
                        "Hey, we're trying to send some analytics over to our devs for the "
                        f"product usage and we got a {r.status_code} response back. Could "
                        "you pls email over to our dev team about this and tell them of the "
                        f"failure with the aforementioned code and this response body: {r.text}"
                    )
            except Exception as err:
                print(f"Unexpected error when connecting to amplitude {err=}, {type(err)=}")


amplitude_client = AmplitudeClient()
