variable "lambda_arn" {
  description = "The arn of the lambda which will subscribe to the topic"
}


variable "lambda_path" {}


module "function_name" {
  source = "github.com/slswt/modules//utils/function_name"
  lambda_path = "${var.lambda_path}"
}

module "release_info" {
  source = "github.com/slswt/modules//utils/release_info"
}

resource "aws_sns_topic" "topic" {
  name = "invoke_function_${module.function_name.snake}_${module.release_info.environment}_${module.release_info.version}"
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
