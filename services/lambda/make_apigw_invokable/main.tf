variable "lambda_apigw_invoke_arn" {
  description = "The apigw uri of the lambda which should be executable by the api gw"
}

variable "lambda_arn" {
  description = "The arn of the lambda"
}

variable "environment" {
  description = "The deployment environment"
}

variable "lambda_path" {
  description = "The relative path of the lambda"
}

data "terraform_remote_state" "microservices_apigw" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "${var.apigw_remote_state_path}/${var.environment}/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "camel_case" {
  source = "github.com/ricsam/serverless_using_terraform//utils/camel_case"
  value  = "${var.lambda_path}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${data.terraform_remote_state.microservices_apigw.rest_api_id}"
  parent_id   = "${data.terraform_remote_state.microservices_apigw.root_resource_id}"
  path_part   = "${module.camel_case.value}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${data.terraform_remote_state.microservices_apigw.rest_api_id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${data.terraform_remote_state.microservices_apigw.rest_api_id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_apigw_invoke_arn}"
}

resource "aws_api_gateway_deployment" "apigw_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
  ]

  rest_api_id = "${data.terraform_remote_state.microservices_apigw.rest_api_id}"
  stage_name  = "${var.environment}"
}

resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${data.terraform_remote_state.microservices_apigw.execution_arn}/*/*"
}
