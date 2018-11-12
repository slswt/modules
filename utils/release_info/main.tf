
data "external" "release_info" {
  program = [
    "slswtinternals",
    "release-info",
    "${path.root}",
  ]
}

output "version" {
  value = "${data.external.release_info.result.version}"
}

output "environment" {
  value = "${data.external.release_info.result.environment}"
}


