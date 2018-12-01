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

resource "aws_s3_bucket" "deployments" {
  bucket = "${module.lambda_deployment_bucket.name}"
  acl    = "private"
}

output "arn" {
  value = "${aws_s3_bucket.deployments.arn}"
}

output "name" {
  value = "${module.lambda_deployment_bucket.name}"
}
