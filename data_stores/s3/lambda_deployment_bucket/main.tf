module "release_info" {
  source = "github.com/slswt/modules//utils/release_info"
}

data "aws_region" "current" {}

module "lambda_deployment_bucket" {
  source = "github.com/slswt/modules//utils/get_name"
  key    = "LAMBDA_DEPLOYMENT_BUCKET"

  data = {
    region = "${data.aws_region.current.name}"
  }
}

resource "aws_s3_bucket" "cors_allow_bucket" {
  bucket = "${module.lambda_deployment_bucket.name}"
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
  value = "${module.lambda_deployment_bucket.name}"
}
