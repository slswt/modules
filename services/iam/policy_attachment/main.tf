variable "role_name" {
  description = "The name of the role on which the policy should be attached"
}

variable "policy" {
  description = "The policy"
}

resource "aws_iam_policy" "attachable_policy" {
  policy = "${var.policy}"
}

resource "aws_iam_role_policy_attachment" "role_attachment" {
  role       = "${var.role_name}"
  policy_arn = "${aws_iam_policy.attachable_policy.arn}"
}


