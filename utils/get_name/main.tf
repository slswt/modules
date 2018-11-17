variable "key" {
  description = "Name key"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "external" "names" {
  program = [
    "slswtinternals",
    "get_name",
    "${path.root}",
    "--region=${data.aws_region.current.name}"
  ]
}

output "name" {
  value = "${data.external.names.result.name}"
}
