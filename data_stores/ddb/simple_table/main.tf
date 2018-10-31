variable "environment" {
  description = "The deployment environment, stage, prod or testing"
}

variable "table_name" {
  description = "The name of the table"
}
variable "read_capacity" {
  description = "The read capacity of the table"
  default = 1
}

variable "write_capacity" {
  description = "The write capacity of the table"
  default = 1
}

variable "stream_enabled" {
  default = false
}
variable "stream_view_type" {
  default = ""
}

variable "ddb_table_name_prefix" {
  
}



locals {
  full_table_name = "${var.ddb_table_name_prefix}${var.table_name}"
}


resource "aws_dynamodb_table" "simple_table" {
  name = "${local.full_table_name}"
  write_capacity  = "${var.write_capacity}"
  read_capacity  = "${var.read_capacity}"
  hash_key       = "id"

  stream_enabled = "${var.stream_enabled}"
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
