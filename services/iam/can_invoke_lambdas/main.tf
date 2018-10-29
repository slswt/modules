variable "environment" {
  description = "The deployment environment"
}

variable "source_lambda_role" {
  description = "The name of the role on which to attach the policy"
}

variable "target_lambda_arn" {
  description = "The lambdas which can be invoked"
}

resource "aws_iam_policy" "policy" {

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:invokeFunction"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.target_lambda_arn}"
      ]
    }
  ]
}
EOF
}



resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = "${var.source_lambda_role}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}
