variable "value" {
  description = "Input variable"
}

data "external" "snake_case" {
  program = [
    "node",
    "${path.module}/snakeCase.js",
    "--value=${var.value}",
  ]
}

output "value" {
  value = "${data.external.snake_case.result.value}"
}


