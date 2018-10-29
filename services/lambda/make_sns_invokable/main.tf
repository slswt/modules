variable "lambda_arn" {
  description = "The arn of the lambda which will subscribe to the topic"
}

variable "environment" {
  description = "The deployment environment"
}
variable "lambda_path" {}


module "function_name" {
  source = "github.com/ricsam/serverless_using_terraform//utils/function_name"
  environment = "${var.environment}"
  lambda_path = "${var.lambda_path}"
}

resource "aws_sns_topic" "topic" {
  name = "invoke_function_${module.function_name.snake}_${var.environment}"
}

resource "aws_sns_topic_subscription" "sns_invokable_lambda" {
  topic_arn = "${aws_sns_topic.topic.arn}"
  protocol  = "lambda"
  endpoint  = "${var.lambda_arn}"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.topic.arn}"
}
