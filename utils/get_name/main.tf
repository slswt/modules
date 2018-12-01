variable "key" {
  description = "Name key"
}
variable "data" {
  description = "json data"
  type = "map"
  default = {}
}


data "external" "names" {
  program = [
    "slswtinternals",
    "get_name",
    "${path.root}",
    "--key=${var.key}",
    "--data=${jsonencode(var.data)}"
  ]
}

output "name" {
  value = "${data.external.names.result.name}"
}
