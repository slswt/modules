variable "path" {
  
}

data "external" "slswt_remote_config" {
  program = [
    "slswtinternals",
    "slswt-remote-config",
    "${path.root}",
  ]
}

module "release_info" {
  source = "github.com/slswt/modules//utils/release_info"
}

data "terraform_remote_state" "microservices_apigw" {
  backend = "s3"

  config {
    bucket = "${data.external.slswt_remote_config.result.remoteStateBucket}"
    key    = "Live/${module.release_info.environment}/${module.release_info.version}/${var.path}/terraform.tfstate"
    region = "${data.external.slswt_remote_config.result.region}"
  }
}
