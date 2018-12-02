output "build_dir" {
  value = "${data.external.webpack_build.result.buildDir}"
}

output "has_errors" {
  value = "${data.external.webpack_build.result.hasErrors}"
}

output "lambda_arn" {
  value = "${zipmap(var.handler_entries, aws_lambda_function.simple_lambda.*.arn)}"
}
output "lambda_qualified_arn" {
  value = "${zipmap(var.handler_entries, aws_lambda_function.simple_lambda.*.qualified_arn)}"
}

output "role_name" {
  value = "${aws_iam_role.lambda_exec_role.name}"
}

output "lambda_apigw_invoke_arn" {
  value = "${zipmap(var.handler_entries, aws_lambda_function.simple_lambda.*.invoke_arn)}"
}

output "handler_entries" {
  value = "${var.handler_entries}"
}

output "lambda_version" {
  value = "${zipmap(var.handler_entries, aws_lambda_function.simple_lambda.*.version)}"
}

output "lambda" {
  value = "${zipmap(var.handler_entries, aws_lambda_function.simple_lambda)}"
}
