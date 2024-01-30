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

import time

from boto3 import client
from botocore.config import Config
from botocore.exceptions import ClientError


class StateHelper:
    """
    The StateHelper class manages the creation and configuration of
    AWS S3 buckets and DynamoDB tables for storing Terraform state.
    """

    def __init__(self, state: str, region: str) -> None:
        """
        Gets provider json and initializes provider variables
        """
        self.bucket_name = state
        self.dynamodb_table = state
        self.region = region

    def manage_aws_state_storage(self) -> None:
        """
        Creates aws state storage resources (S3 bucket and DynamoDB table)
        if they do not exist.
        """
        s3 = client("s3", config=Config(region_name=self.region))
        dynamodb = client("dynamodb", config=Config(region_name=self.region))

        # checks if bucket exists
        try:
            s3.head_bucket(
                Bucket=self.bucket_name,
            )
        except ClientError as e:
            if e.response["Error"]["Code"] == "AuthFailure":
                raise Exception(
                    "The AWS Credentials are not configured properly.\n"
                    "https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html#configuration"
                    "for more information."
                )
            elif e.response["Error"]["Code"] == "AccessDenied":
                raise Exception(
                    f"We were unable to access the S3 bucket, {self.bucket_name} on your AWS account.\n"
                    "Possible Issues: \n"
                    " - Bucket name is not unique and might be present in some other Account. \n"
                    "Try updating the name in Configuration file to something else.\n"
                    " - It could also mean that your AWS account has insufficient permissions.\n"
                    "Please fix these issues and try again!"
                )
            elif e.response["Error"]["Code"] == "404":
                print("S3 bucket for terraform state not found, creating a new one")
                self._setup_bucket(
                    s3_client=s3,
                    region=self.region,
                    bucket_name=self.bucket_name,
                    bucket_exists=False,
                )
            else:
                raise Exception(
                    f"{e.response['Error']['Code']} error with the message "
                    f"{e.response['Error']['Message']}"
                )

        # sets bucket versioning and lifecycle rules
        self._setup_bucket(
            s3_client=s3,
            region=self.region,
            bucket_name=self.bucket_name,
            bucket_exists=True,
        )

        # describe dynamodb table
        # create if error occurs in table describe
        try:
            dynamodb.describe_table(TableName=self.dynamodb_table)
        except ClientError as e:
            if e.response["Error"]["Code"] != "ResourceNotFoundException":
                raise Exception(
                    "When trying to determine the status of the state dynamodb table, we got an "
                    f"{e.response['Error']['Code']} error with the message "
                    f"{e.response['Error']['Message']}"
                )
            print("Dynamodb table for terraform state not found, creating a new one")
            dynamodb.create_table(
                TableName=self.dynamodb_table,
                KeySchema=[{"AttributeName": "LockID", "KeyType": "HASH"}],
                AttributeDefinitions=[{"AttributeName": "LockID", "AttributeType": "S"}],
                BillingMode="PROVISIONED",
                ProvisionedThroughput={
                    "ReadCapacityUnits": 20,
                    "WriteCapacityUnits": 20,
                },
            )

    def _setup_bucket(self, s3_client, region: str, bucket_name: str, bucket_exists: bool = False):
        """
        Creates state bucket if it does not exist.
        Configures bucket versioning and lifecycle rules.
        """
        if not bucket_exists:
            try:
                if region == "us-east-1":
                    s3_client.create_bucket(Bucket=bucket_name)
                else:
                    s3_client.create_bucket(
                        Bucket=bucket_name,
                        CreateBucketConfiguration={"LocationConstraint": region},
                    )
                time.sleep(10)
            except ClientError as e:
                raise Exception(
                    f"When trying to create a new bucket with name {bucket_name}, we got an "
                    f"{e.response['Error']['Code']} error with the message "
                    f"{e.response['Error']['Message']}"
                )

        # we are not checking for bucket encryption
        # as all new buckets are encrypted by default since 2016

        # checking for bucket versioning
        # enable if not enabled
        try:
            response = s3_client.get_bucket_versioning(Bucket=bucket_name).get("Status")
            if response == "Enabled":
                print("Versioning is already enabled on state bucket")
            else:
                print("Versioning is not yet enabled on state bucket")
                s3_client.put_bucket_versioning(
                    Bucket=bucket_name,
                    VersioningConfiguration={"Status": "Enabled"},
                )
                print("Versioning is now enabled on state bucket")
        except ClientError as e:
            if e.response["Error"]["Code"] != "NoSuchBucket":
                raise Exception(
                    f"When trying to check if versioning is enabled on the state bucket, we got an "
                    f"{e.response['Error']['Code']} error with the message "
                    f"{e.response['Error']['Message']}"
                )
            print("State bucket does not exist")

        # checking for bucket lifecycle configuration
        # enable if it does not exist
        try:
            response = s3_client.get_bucket_lifecycle_configuration(Bucket=bucket_name).get("Rules")
            if response is not None:
                print("Bucket lifecycle configuration already exists on state bucket")
        except ClientError as e:
            if e.response["Error"]["Code"] == "NoSuchLifecycleConfiguration":
                print("Bucket lifecycle configuration does not exists on state bucket")
                s3_client.put_bucket_lifecycle(
                    Bucket=bucket_name,
                    LifecycleConfiguration={
                        "Rules": [
                            {
                                "ID": "default",
                                "Prefix": "/",
                                "Status": "Enabled",
                                "NoncurrentVersionTransition": {
                                    "NoncurrentDays": 30,
                                    "StorageClass": "GLACIER",
                                },
                                "NoncurrentVersionExpiration": {"NoncurrentDays": 60},
                                "AbortIncompleteMultipartUpload": {"DaysAfterInitiation": 10},
                            },
                        ]
                    },
                )
                print("Bucket lifecycle configuration now exsits on state bucket")
