variable "name" {
  type    = string
  default = "hive-eks-cluster"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# This controls the 2-phase apply
variable "deploy_app" {
  type    = bool
  default = true
}
