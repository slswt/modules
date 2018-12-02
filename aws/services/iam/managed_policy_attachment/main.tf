variable "key" {
  description = "The key of the remote terraform tfstate (for the managed policy) in the bucket containg an output of arn, which is the policy arn."
}
variable "role" {
  description = "The name of the role on which to attach the policy"
}

data "terraform_remote_state" "remote_managed_policy" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "${var.key}"
    region = "eu-central-1"
  }
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = "${var.role}"
  policy_arn = "${data.terraform_remote_state.remote_managed_policy.arn}"
}
