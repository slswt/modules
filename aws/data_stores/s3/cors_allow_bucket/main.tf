
variable "id" {
  description = "The id of the bucket resource"
}
variable "acl" {
  description = "The acl value of the bucket"
}

locals {
  deployment_uri = "${format("%s/aws_s3_bucket/%s", replace(path.root, "/^.*\\.Live\\/(.*)$/", "$1"), var.id)}"
  full_bucket_name = "${md5(local.deployment_uri)}"
}


resource "aws_s3_bucket" "cors_allow_bucket" {
  bucket = "${local.full_bucket_name}"
  acl    = "${var.acl}"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}
output "arn" {
  value = "${aws_s3_bucket.cors_allow_bucket.arn}"
}

output "name" {
  value = "${local.full_bucket_name}"
}

output "deployment_uri" {
  value = "${local.deployment_uri}"
}
