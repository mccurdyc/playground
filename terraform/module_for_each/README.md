## Problem Statement

I was trying to debug an issue where I was using `for_each` in a "module1" block,
which generated some output that was used as list input to "module2". "module2"
was using `toset()` to remove ordering and duplicates.

I was fighting with the following error:

```
  on main.tf line 28, in resource "null_resource" "onetwothree":
  28:   for_each = toset([random_pet.generated.id])
The "for_each" value depends on resource attributes that cannot be determined
until apply, so Terraform cannot predict how many instances will be created.
To work around this, use the -target argument to first apply only the
resources that the for_each depends on.
```

The following is some minimal code to reproduce the error, but was less representative
of the problem that I was trying to solve. Instead, the following was use to highlight
that `toset()` forced a two-phase apply for generated, or unknown, inputs.

```
# cat main.tf
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
provider "random" {
  # Configuration options
}
resource "random_pet" "generated" {
  length    = 3
  separator = "-"
}
resource "null_resource" "onetwothree" {
  for_each = toset([random_pet.generated.id])
  provisioner "local-exec" {
    command = "echo ${each.key}"
  }
}
```

## Want to try the example source code?
```
(
cd $(mktemp -d)
git clone git@github.com:mccurdyc/terraform_sandbox.git
cd terraform_sandbox/examples/module_for_each
terraform init && terraform apply -auto-approve
)
```
