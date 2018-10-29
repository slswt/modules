variable "environment" {
  description = "The deployment environment"
}

variable "lambda_path" {
  description = "The name of the function"
}

variable "module_path" {
  description = "The path of the serverless module"
}

variable "service" {
  description = "The service relative path"
}

module "simple_lambda" {
  source = "../simple_lambda"
  environment     = "${var.environment}"
  lambda_path   = "${var.lambda_path}"
  handler_entries = ["apigw", "sns", "invoke"]
  module_path     = "${var.module_path}"
  service         = "${var.service}"
}

module "make_apigw_invokable" {
  source                  = "../make_apigw_invokable"
  lambda_apigw_invoke_arn = "${module.simple_lambda.lambda_apigw_invoke_arn[0]}"
  lambda_arn              = "${module.simple_lambda.lambda_arn[0]}"
  environment             = "${var.environment}"
  function_name           = "${var.function_name}"
}

module "make_sns_invokable" {
  source      = "github.com/ricsam/serverless_using_terraform//services/lambda/make_sns_invokable"
  environment = "${var.environment}"
  lambda_arn  = "${module.simple_lambda.lambda_arn[1]}"
  lambda_path   = "${var.lambda_path}"
}
