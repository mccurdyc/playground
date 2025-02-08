terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "null" {
  # Configuration options
}

variable "regions" {
  type    = set(string)
  default = ["a", "b", "c"]
}

module "appA" {
  source          = "./mod"
  generated_input = var.regions
}

output "outA" {
  value = module.appA.generated_outputs
}

module "appB" {
  source          = "./mod"
  generated_input = module.appA.generated_outputs
}

output "outB" {
  value = module.appB.generated_outputs
}

module "appC" {
  source          = "./mod"
  for_each        = var.regions
  generated_input = module.appA.generated_outputs
}

locals {
  cOut = { for k, v in module.appC : k => v.generated_outputs }
}

resource "null_resource" "foo" {
  provisioner "local-exec" {
    command = "echo ${jsonencode(local.cOut)}"
  }
}
