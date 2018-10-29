variable "value" {
  description = "input value"
}

output "value" {
  value = "${replace(replace(var.value, "\"", "\\\""), "\n", "\\n")}"
}

