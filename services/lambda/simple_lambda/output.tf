output "lambda_arn" {
  value = "${zipmap(local.entries, aws_lambda_function.simple_lambda.*.arn)}"
}
output "role_name" {
  value = "${aws_iam_role.lambda_exec_role.name}"
}

output "entries" {
  value = "${local.entries}"
}

output "lambda_version" {
  value = "${zipmap(local.entries, aws_lambda_function.simple_lambda.*.version)}"
}
