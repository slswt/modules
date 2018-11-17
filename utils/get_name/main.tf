variable "key" {
  description = "Name key"
}

data "external" "names" {
  program = [
    "slswtinternals",
    "get_name",
    "${path.root}",
    "--key=${var.key}"
  ]
}

output "name" {
  value = "${data.external.names.result.name}"
}
