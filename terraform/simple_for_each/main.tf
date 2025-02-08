terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }
}

provider "null" {
  # Configuration options
}

variable "envs" {
  type = map(map(string))
  default = {
    "foo" = { "name" = "foo", "account_id" = 123 }
    "bar" = { "name" = "bar", "account_id" = 456 }
    "baz" = { "account_id" = 789 }
  }
}

resource "null_resource" "foo" {
  for_each = var.envs

  provisioner "local-exec" {
    command = "echo ${each.value["account_id"]} ${lookup(each.value, "name", "default")}"
  }
}
