variable "environment" {
  description = "The deployment environment, dev, stage, prod"
}

output "ddb_table_name_prefix" {
  value = "serverless_using_terraform-${var.environment}-"
}

locals {
  s3_bucket_name_prefix = "serverless_using_terraform-${var.environment}-"
}

output "s3_bucket_name_prefix" {
  value = "${local.s3_bucket_name_prefix}"
}

output "lambda_name_prefix" {
  value = "stc_${var.environment}"
}

output "lambda_deployment_bucket" {
  value = "${local.s3_bucket_name_prefix}lambda-deployments"
}
