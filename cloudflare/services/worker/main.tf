variable "service" {
  
}

variable "id" {
  
}

variable "zone" {
  
}




data "external" "webpack_build" {
  program = [
    "slswtinternals",
    "cloudflare_worker_build",
    "--liveFolder=${path.root}",
    "--service=${var.service}",
    "--id=${var.id}",
  ]
}

resource "cloudflare_worker_script" "worker" {
  zone = "${var.zone}"
  content = "${file("worker.js")}"
}

