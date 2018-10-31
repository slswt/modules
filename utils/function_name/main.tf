variable "lambda_path" {}

variable "environment" {}

variable "lambda_name_prefix" {}


variable "entry" {
  description = "The entry function in the service.js file (default used if just the base_name is accessed)"
  default     = ""
}

locals {
  function_base_name = "${var.lambda_name_prefix}_${module.snake_case.value}"
  base_entry_format = "%s_%s"
}
module "snake_case" {
  source = "github.com/slswt/modules//utils/snake_case"
  value  = "${var.lambda_path}"
}


output "md5" {
  value = "${md5(format(local.base_entry_format, local.function_base_name, var.entry))}"
}

output "snake" {
  value = "${module.snake_case.value}"
}

output "base" {
  value = "${local.function_base_name}"
}

output "base_entry_format" {
  value = "${local.base_entry_format}"
}
