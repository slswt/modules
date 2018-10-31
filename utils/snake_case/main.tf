variable "value" {
  description = "Input variable"
}

data "external" "snake_case" {
  program = [
    "slswtinternals",
    "snake_case",
    "${var.value}",
  ]
}

output "value" {
  value = "${data.external.snake_case.result.value}"
}


