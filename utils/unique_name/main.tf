
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
  value = "${substr(format("%s%s", var.id, md5(format("%s%s", var.id, var.path))), 0, var.length)}"
}
