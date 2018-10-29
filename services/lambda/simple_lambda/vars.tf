variable "service" {
  description = "The path to the service (.js file)"
}

variable "webpack_mode" {
  description = "The mode in which to run webpack and transpile the service (production or development)"
  default     = "production"
}

variable "environment" {
  description = "The deployment environment, dev, stage, prod"
  default     = "stage"
}

variable "timeout" {
  default = 5
}

variable "memory_size" {
  default = 256
}

variable "handler_entries" {
  type        = "list"
  description = "The constant name of the exported functions in the service entry file"
}

variable "module_path" {
  description = "The path of the lambda module"
}

variable "lambda_path" {
  description = "The (relative, namespacing) path of the lambda"
}

variable "lambda_environment" {
  description = "Environment vars to be proviced to the lambda"
  default     = {}
  type        = "map"
}

variable "node_externals_whitelist" {
  description = "The node externals whitelist, look at node externals github"
  default     = []
  type        = "list"
}
