data "aws_region" "current" {}
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

data "terraform_remote_state" "state" {
  backend = "s3"

  config {
    bucket = "${data.external.slswt_remote_config.result.tfRemoteStateBucket}"
    key    = "${data.external.deployment_data.result.globalDeploymentURI}/${data.aws_region.current.name}.terraform.tfstate"
    region = "${data.external.slswt_remote_config.result.region}"
  }
}

output "result" {
  value = "${data.terraform_remote_state.state}"
}
