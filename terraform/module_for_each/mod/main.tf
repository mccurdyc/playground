variable "generated_input" {
  type = set(string)
}

locals {
  # motivation for this pattern came from https://github.com/terraform-google-modules/terraform-google-network/blob/d88508f7e1cb11fe6a07f503da7dc98bef58c99d/modules/routes/main.tf
  generated_input = {
    for input in var.generated_input :
    input => { "region" : input }
  }
}

data "null_data_source" "generated" {
  for_each = local.generated_input
  inputs = {
    region = each.key
  }
}

output "generated_outputs" {
  value = [
    for output in data.null_data_source.generated :
    # double input just to show that we did something to the input.
    format("%s%s", output.outputs.region, output.outputs.region)
  ]
}
