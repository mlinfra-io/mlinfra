"""
This file is responsible for configuring and running terraform `apply` command
Apply function undergoes the following steps:
- checking if terraform is installed
- checking if following versions are correct:
    - terraform
    - mlops_cli
- checking if the platinfra config file exists
- clean .mlops_infra folder
- check cloud credentials
- check if region has three AZs
- Generate terraform state storage
- loop through items in config file
    - generate list of modules (should come from stack processor module)
    - create a different apply function for different deployment types
        - order modules in order of application
        - apply terraform modules with -target
"""


class Apply:
    def __init__(self):
        pass
