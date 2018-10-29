variable "environment" {
  description = "The deployment environment"
}

variable "module_path" {
  description = "The path of the lambda module"
}

variable "lambda_path" {
  description = "pathed name of the lambda function"
}

locals {
  sns_lambda_arn = "${module.simple_lambda.lambda_arn[0]}"
}

module "simple_lambda" {
  source          = "../simple_lambda"
  service         = "./service.js"
  handler_entries = ["sns", "invoke"]
  environment     = "${var.environment}"
  module_path     = "${var.module_path}"
  lambda_path     = "${var.lambda_path}"
}

module "managed_policy_attachment_of_elastic_search" {
  source = "github.com/slswt/modules//services/iam/managed_policy_attachment"
  key    = "Live/services/iam/policies/elastic_search/${var.environment}/terraform.tfstate"
  role   = "${module.simple_lambda.role_name}"
}

module "managed_policy_attachment_of_dynamo_db_updates_queue" {
  source = "github.com/slswt/modules//services/iam/managed_policy_attachment"
  key    = "Live/services/iam/policies/dynamo_db_updates_queue/${var.environment}/terraform.tfstate"
  role   = "${module.simple_lambda.role_name}"
}

module "make_sns_invokable" {
  source      = "github.com/slswt/modules//services/lambda/make_sns_invokable"
  environment = "${var.environment}"
  lambda_arn  = "${local.sns_lambda_arn}"
  lambda_path = "${var.lambda_path}"
}

output "has_errors" {
  value = "${module.simple_lambda.has_errors}"
}

output "lambda_arn" {
  value = "${module.simple_lambda.lambda_arn}"
}

output "handler_entries" {
  value = "${module.simple_lambda.handler_entries}"
}
