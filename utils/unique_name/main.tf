variable "environment" {}

variable "length" {
  default = 32
}

variable "id" {
  default = "id"
}

variable "path" {
  description = "The unique path"
}

output "value" {
  value = "${substr(format("%s%s", var.id, md5(format("%s%s%s", var.id, var.path, var.environment))), 0, var.length)}"
}
