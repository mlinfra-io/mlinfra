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

import pytest
from mlinfra.terraform.terraform import Terraform


class Test:
    # Generates a list of modules to be applied via the -target function of terraform
    def test_generate_modules_list(self, mocker):
        # Mock the necessary dependencies
        mocker.patch("os.listdir", return_value=["module1.tf.json"])
        mocker.patch(
            "builtins.open",
            mocker.mock_open(
                read_data='{"module": {"vpc": {"source": "./modules/cloud/aws/vpc","name": "aws-lakefs-k8s-vpc"}}}'
            ),
        )

        # Initialize the class object
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)

        # Invoke the method
        modules_list = terraform.generate_modules_list()

        # Assert the result
        assert modules_list == ["module.vpc"]

    # Returns a string of terraform targets for the plan command
    def test_plan_output(self, mocker):
        # Mock the necessary dependencies
        mocker.patch(
            "mlinfra.terraform.terraform.Terraform.generate_terraform_config",
            return_value=("stack_name", "state_name", "aws_region", "provider"),
        )
        mocker.patch("mlinfra.terraform.terraform.Terraform.check_cloud_credentials")
        mocker.patch("mlinfra.terraform.terraform.Terraform.check_region_has_three_azs")
        mocker.patch("mlinfra.terraform.terraform.Terraform.check_terraform_state_storage")
        mocker.patch(
            "mlinfra.terraform.terraform.Terraform.generate_modules_list",
            return_value=["module.module1", "module.module2"],
        )

        # Initialize the class object
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)

        # Invoke the method
        plan_output = terraform.plan()

        # Assert the result
        assert plan_output == " -target=module.module1 -target=module.module2"

    # Runs preliminary checks before generating the terraform config file
    def test_generate_terraform_config(self, mocker):
        # Mock the necessary dependencies
        mocker.patch("mlinfra.utils.utils.check_terraform_installed")
        mocker.patch("mlinfra.terraform.terraform.Terraform.check_config_file_exists")
        mocker.patch("mlinfra.terraform.terraform.Terraform.clean_ml_infra_folder")
        mocker.patch(
            "mlinfra.terraform.terraform.Terraform.process_config_file",
            return_value=("stack_name", "state_name", "aws_region", "provider"),
        )

        # Initialize the class object
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)

        # Invoke the method
        stack_name, state_name, aws_region, provider = terraform.generate_terraform_config()

        # Assert the result
        assert stack_name == "stack_name"
        assert state_name == "state_name"
        assert aws_region == "aws_region"
        assert provider == "provider"

    # The file specified in stack_config_path does not exist
    def test_check_config_file_exists_file_not_found(self, mocker):
        # Mock the necessary dependencies
        mocker.patch("os.path.isfile", return_value=False)

        # Initialize the class object
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)

        # Invoke and assert the exception
        with pytest.raises(FileNotFoundError):
            terraform.check_config_file_exists()

    # The stack config file is not a valid yaml file
    def test_check_config_file_exists_invalid_yaml(self, mocker):
        # Mock the necessary dependencies
        mocker.patch("os.path.isfile", return_value=True)
        mocker.patch("builtins.open", mocker.mock_open(read_data="invalid_yaml"))

        # Initialize the class object
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)

        # Invoke and assert the exception
        with pytest.raises(ValueError):
            terraform.check_config_file_exists()

    # The stack config file is missing required keys
    def test_check_config_file_exists_missing_keys(self, mocker):
        # Mock the necessary dependencies
        mocker.patch("os.path.isfile", return_value=True)
        mocker.patch("builtins.open", mocker.mock_open(read_data='{"name": "stack_name"}\n'))

        # Initialize the class object
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)

        # Invoke and assert the exception
        with pytest.raises(ValueError):
            terraform.check_config_file_exists()

    # The test checks if the method 'generate_terraform_config' returns a tuple of strings representing the state name and AWS region
    def test_returns_state_name_and_aws_region_with_mocked_yaml_safe_load_with_mocked_configure_provider(
        self, mocker
    ):
        mocker.patch.object(Terraform, "check_config_file_exists")
        mocker.patch.object(Terraform, "clean_ml_infra_folder")
        mocker.patch("os.path.isfile", return_value=True)
        mocker.patch.object(
            Terraform,
            "process_config_file",
            return_value=("stack_name", "state_name", "aws_region", "provider"),
        )
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)
        stack_name, state_name, aws_region, provider = terraform.generate_terraform_config()
        assert stack_name == "stack_name"
        assert state_name == "state_name"
        assert aws_region == "aws_region"
        assert provider == "provider"

    # check_terraform_installed returns an error message when an exception is encountered
    # def test_check_terraform_installed_returns_error_message(self, mocker):
    #     mocker.patch("subprocess.run", side_effect=Exception("An error occurred"))
    #     result = check_terraform_installed()
    #     assert isinstance(result, str)
    #     assert "An error occurred while checking the Terraform version" in result

    # stack config file does not exist, raises FileNotFoundError
    def test_stack_config_file_not_found(self, mocker):
        mocker.patch("os.path.isfile", return_value=False)
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)
        with pytest.raises(FileNotFoundError):
            terraform.check_config_file_exists()

    # stack config file is invalid YAML, raises ValueError
    def test_stack_config_file_invalid_yaml(self, mocker):
        mocker.patch("os.path.isfile", return_value=True)
        mocker.patch("builtins.open", mocker.mock_open(read_data="invalid_yaml"))
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)
        with pytest.raises(ValueError):
            terraform.check_config_file_exists()

    # stack config file is missing required keys, raises ValueError
    def test_stack_config_file_missing_keys(self, mocker):
        mocker.patch("os.path.isfile", return_value=True)
        mocker.patch("builtins.open", mocker.mock_open(read_data='{"name": "stack_name"}\n'))
        stack_config_path = "path/to/stack/config.yaml"
        terraform = Terraform(stack_config_path)
        with pytest.raises(ValueError):
            terraform.check_config_file_exists()
