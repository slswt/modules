
variable "service" {
  description = "The path to the service (.js file)"
}

variable "id" {
  default = "${var.service}"
}

variable "timeout" {
  default = 5
}

variable "memory_size" {
  default = 256
}

variable "lambda_environment" {
  description = "Environment vars to be proviced to the lambda"
  type        = "map"
  default     = {}
}

variable "lambda_publish" {
  default = false
}
