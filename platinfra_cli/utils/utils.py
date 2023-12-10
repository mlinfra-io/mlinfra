import os
import json
import shutil
import subprocess
from .constants import TF_PATH


def clean_tf_directory():
    if os.path.isdir(TF_PATH):
        shutil.rmtree(TF_PATH)


def generate_tf_json(module_name: str, json_module: json):
    with open(f"./{TF_PATH}/{module_name}.tf.json", "w", encoding="utf-8") as tf_json:
        json.dump(json_module, tf_json, ensure_ascii=False, indent=2)


def check_terraform_version():
    try:
        # Run 'terraform version' command in the shell
        result = subprocess.run(
            ["terraform", "version"], capture_output=True, text=True, check=True
        )

        # Extract the version information from the output
        output_lines = result.stdout.split("\n")
        for line in output_lines:
            if line.startswith("Terraform"):
                version_info = line.split()[1]
                print(f"Terraform is installed. Version: {version_info}")

    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        print("Terraform is not installed or an error occurred.")
        print("Please install Terraform and try again.")
        exit(1)
