data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "external" "webpack_build" {
  program = [
    "slswtinternals",
    "build_lambda",
    "--liveFolder=${path.root}",
    "--service=${var.service}",
  ]
}

resource "aws_s3_bucket_object" "lambda_zip_upload" {
  bucket       = "${data.external.webpack_build.result.bucket}"
  key          = "${data.external.webpack_build.result.bucketObjectKey}"
  source       = "${data.external.webpack_build.result.zipFilePath}"
  content_type = "application/zip"
}

locals {
  log_group_access_prefix = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/"
  entries                 = "${split("|", data.external.webpack_build.result.entries)}"
  functionNames           = "${split("|", data.external.webpack_build.result.functionNames)}"
  functionDescriptions    = "${split("|", data.external.webpack_build.result.functionDescriptions)}"
  lambdaHandlers          = "${split("|", data.external.webpack_build.result.lambdaHandlers)}"

  environment = {
    region      = "${data.external.webpack_build.result.env_region}"
    project     = "${data.external.webpack_build.result.env_project}"
    platform    = "${data.external.webpack_build.result.env_platform}"
    account     = "${data.external.webpack_build.result.env_account}"
    environment = "${data.external.webpack_build.result.env_environment}"
    version     = "${data.external.webpack_build.result.env_version}"
    path        = "${data.external.webpack_build.result.env_path}"
  }
}

resource "aws_lambda_function" "simple_lambda" {
  depends_on = ["aws_s3_bucket_object.lambda_zip_upload"]

  count = "${length(local.entries)}"

  function_name = "${local.functionNames[count.index]}"

  s3_bucket = "${data.external.webpack_build.result.bucket}"
  s3_key    = "${data.external.webpack_build.result.bucketObjectKey}"

  handler = "${local.lambdaHandlers[count.index]}"
  runtime = "nodejs8.10"

  timeout     = "${var.timeout}"
  memory_size = "${var.memory_size}"

  role = "${aws_iam_role.lambda_exec_role.arn}"

  environment = {
    variables = "${merge(
      var.lambda_environment,
      local.environment
    )}"
  }

  description = "${local.functionDescriptions[count.index]}"

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

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_group" {
  count = "${length(local.entries)}"
  name  = "/aws/lambda/${local.functionNames[count.index]}"
}

resource "aws_iam_policy" "cloudwatch_attachable_policy" {
  count = "${length(local.entries)}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream"
      ],
      "Effect": "Allow",
      "Resource": "${local.log_group_access_prefix}${local.functionNames[count.index]}:*"
    },
    {
      "Action": [
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "${local.log_group_access_prefix}${local.functionNames[count.index]}:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloud_watch_role_attachment" {
  count      = "${length(local.entries)}"
  role       = "${aws_iam_role.lambda_exec_role.name}"
  policy_arn = "${aws_iam_policy.cloudwatch_attachable_policy.*.arn[count.index]}"
}
