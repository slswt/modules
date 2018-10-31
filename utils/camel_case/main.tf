variable "value" {
  description = "Input variable"
}

data "external" "camel_case" {
  program = [
    "slswtinternals",
    "camel_case",
    "${var.value}",
  ]
}

output "value" {
  value = "${data.external.camel_case.result.value}"
}


