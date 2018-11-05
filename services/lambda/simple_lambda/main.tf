data "external" "webpack_build" {
  program = [
    "slswtinternals",
    "build_lambda",
    "--environment=${var.environment}",
    "--functionName=${var.lambda_path}",
    "--webpackMode=${var.webpack_mode}",

    # The location of the service path (where the tf file of the module service is (and javascript files))
    "--path=${var.module_path}",

    # The path of where the root module is installed
    "--modulePath=${path.module}",

    # The path of the tf files for the microservice (the build directory is here)
    "--rootPath=${path.root}",

    # The relative path from the root path to the javascript entry file (relative path, e.g. ./service.js)
    "--servicePath=${var.service}",

    "--nodeExternalsWhitelist=${jsonencode(var.node_externals_whitelist)}",
  ]
}

locals {
  log_group_access_prefix = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/"
  fn_names                = "${data.null_data_source.function_names.*.outputs.function_name}"

  s3_key = "${module.function_name.snake}.${data.external.webpack_build.result.completeHash}.zip"
}

resource "aws_s3_bucket_object" "lambda_zip_upload" {
  bucket       = "${aws_s3_bucket.lambda_deployment_bucket.id}"
  key          = "${local.s3_key}"
  source       = "${data.external.webpack_build.result.zipFile}"
  content_type = "application/zip"
}

module "function_name" {
  source             = "github.com/slswt/modules//utils/function_name"
  environment        = "${var.environment}"
  lambda_path        = "${var.lambda_path}"
  lambda_name_prefix = "${var.lambda_name_prefix}"
}

data "null_data_source" "function_names" {
  count = "${length(var.handler_entries)}"

  inputs = {
    function_name = "${md5(format(module.function_name.base_entry_format, module.function_name.base, var.handler_entries[count.index]))}"
  }
}

resource "aws_s3_bucket" "lambda_deployment_bucket" {
  bucket = "${md5(jsonencode(local.fn_names))}-lambdas-${data.aws_region.current.name}"
}

resource "aws_lambda_function" "simple_lambda" {
  depends_on = ["aws_s3_bucket_object.lambda_zip_upload"]

  count = "${length(var.handler_entries)}"

  function_name = "${local.fn_names[count.index]}"

  s3_bucket = "${aws_s3_bucket.lambda_deployment_bucket.id}"
  s3_key    = "${local.s3_key}"

  handler = "service.${var.handler_entries[count.index]}"
  runtime = "nodejs8.10"

  timeout     = "${var.timeout}"
  memory_size = "${var.memory_size}"

  role = "${aws_iam_role.lambda_exec_role.arn}"

  environment = {
    variables = "${var.lambda_environment}"
  }

  description = "${var.lambda_path}/${var.handler_entries[count.index]}@${var.environment}"

  publish = "${var.lambda_publish}"
}

resource "aws_iam_role" "lambda_exec_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_group" {
  count = "${length(var.handler_entries)}"
  name  = "/aws/lambda/${local.fn_names[count.index]}"
}

resource "aws_iam_policy" "cloudwatch_attachable_policy" {
  count = "${length(var.handler_entries)}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream"
      ],
      "Effect": "Allow",
      "Resource": "${local.log_group_access_prefix}${local.fn_names[count.index]}:*"
    },
    {
      "Action": [
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "${local.log_group_access_prefix}${local.fn_names[count.index]}:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloud_watch_role_attachment" {
  count      = "${length(var.handler_entries)}"
  role       = "${aws_iam_role.lambda_exec_role.name}"
  policy_arn = "${aws_iam_policy.cloudwatch_attachable_policy.*.arn[count.index]}"
}
