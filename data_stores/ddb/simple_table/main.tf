variable "read_capacity" {
  description = "The read capacity of the table"
  default     = 1
}

variable "write_capacity" {
  description = "The write capacity of the table"
  default     = 1
}

variable "id" {
  default = "default_id"
}

variable "stream_enabled" {
  default = false
}

variable "stream_view_type" {
  default = ""
}

locals {
  full_table_name = "${md5(format("%s/dynamo_db/%s", replace(path.root, "/^.*\\.Live\\/(.*)$/", ".Live/$1"), var.id))}"
}

resource "aws_dynamodb_table" "simple_table" {
  name           = "${local.full_table_name}"
  write_capacity = "${var.write_capacity}"
  read_capacity  = "${var.read_capacity}"
  hash_key       = "id"

  stream_enabled   = "${var.stream_enabled}"
  stream_view_type = "${var.stream_view_type}"

  attribute {
    name = "id"
    type = "S"
  }
}

output "name" {
  value = "${local.full_table_name}"
}

output "arn" {
  value = "${aws_dynamodb_table.simple_table.arn}"
}

output "stream_arn" {
  value = "${aws_dynamodb_table.simple_table.stream_arn}"
}
