terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

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

resource "null_resource" "bar" {
  provisioner "local-exec" {
    command = "echo 'foo'"
  }
}
