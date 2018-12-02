variable "id" {
}

locals {
  deployment_uri = "${format("%s/aws_appsync_graphql_api/%s", replace(path.root, "/^.*\\.Live\\/(.*)$/", "$1"), var.id)}"
  name = "${md5(local.deployment_uri)}"
}

resource "aws_appsync_graphql_api" "graphql_api" {
  authentication_type = "AWS_IAM"
  name = "${local.name}"
}

output "api_id" {
  value = "${aws_appsync_graphql_api.graphql_api.id}"
}
output "api_arn" {
  value = "${aws_appsync_graphql_api.graphql_api.arn}"
}
output "deployment_uri" {
  value = "${local.deployment_uri}"
}
