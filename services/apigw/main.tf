variable "id" {
  default = "default_id"
}


data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


locals {
  deployment_uri = "${format(
    "%s/aws/%s/aws_api_gateway_rest_api/%s",
    replace(path.root, "/^.*\\.Live\\/(.*)$/", ".Live/$1"),
    data.aws_caller_identity.current.account_id,
    "aws_api_gateway_rest_api",
    data.aws_region.current.name,
    var.id
  )}"
  name = "${md5(local.deployment_uri)}"
}

resource "aws_api_gateway_rest_api" "screed_microservices" {
  name = "${local.name}"
}


output "rest_api_id" {
  value = "${aws_api_gateway_rest_api.screed_microservices.id}"
}
output "root_resource_id" {
  value = "${aws_api_gateway_rest_api.screed_microservices.root_resource_id}"
}

output "execution_arn" {
  value = "${aws_api_gateway_rest_api.screed_microservices.execution_arn}"
}

output "deployment_uri" {
  value = "${local.deployment_uri}"
}


