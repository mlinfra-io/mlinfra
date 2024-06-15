# This needs to be added explicitly to all modules
# relying on a non-hashicorp provider. See:
# https://discuss.hashicorp.com/t/using-a-non-hashicorp-provider-in-a-module/21841
terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.5"
    }
  }
}
