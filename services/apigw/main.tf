variable "id" {
  default = "default_id"
}

locals {
  name = "${md5(format("%s/api_gateway/%s", replace(path.root, "/^.*\\.Live\\/(.*)$/", ".Live/$1"), var.id))}"
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

