variable "value" {
  description = "Input variable"
}

data "external" "camel_case" {
  program = [
    "node",
    "${path.module}/camelCase.js",
    "--value=${var.value}",
  ]
}

output "value" {
  value = "${data.external.camel_case.result.value}"
}


