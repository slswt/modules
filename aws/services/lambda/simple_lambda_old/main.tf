data "external" "webpack_build" {
  program = [
    "slswtinternals",
    "build_lambda",
    "--webpackMode=${var.webpack_mode}",
    "--nodeExternalsWhitelist=${jsonencode(var.node_externals_whitelist)}",
  ]
}

locals {
  log_group_access_prefix = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/"
}

module "lambda_deployment_bucket" {
  source = "github.com/slswt/modules//utils/get_name"
  key = "LAMBDA_DEPLOYMENT_BUCKET"
}

resource "aws_s3_bucket_object" "lambda_zip_upload" {
  bucket       = "${module.lambda_deployment_bucket.name}"
  key          = "${data.external.webpack_build.result.s3ObjectKey}"
  source       = "${data.external.webpack_build.result.zipFile}"
  content_type = "application/zip"
}

data "null_data_source" "function_names" {
  count = "${length(var.handler_entries)}"

  inputs = {
    function_name = "${md5(format(module.function_name.base_entry_format, module.function_name.base, var.handler_entries[count.index]))}"
  }
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

  # see the following regarding publish https://github.com/terraform-providers/terraform-provider-aws/issues/4088
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
