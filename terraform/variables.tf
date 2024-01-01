variable "region" {
  type = string
  default = "us-east-1"
}

variable "main_network_block" {
  type = string
  default = "10.0.0.0/16"
  description = "CIDR block which used in vpc"
}

variable "name_prefix" {
  type = string
  default = "cluster-1"
  description = "this is prefix name used on all infrastructure object name created in AWS"
}
variable "environment" {
  type    = string
  default = "test"
}
variable "admin_users" {
  type        = list(string)
  default     = ["triple-a"]
  description = "List of Kubernetes admins."
}

variable "developer_users" {
  type        = list(string)
  default     = []
  description = "List of Kubernetes developers."
}
