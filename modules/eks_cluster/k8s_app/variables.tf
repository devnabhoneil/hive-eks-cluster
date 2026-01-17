variable "cluster_name" {
  type = string
}
variable "region" {
  type = string
}

variable "app_namespace" {
  type = string
}

variable "app_name" {
  type = string
}

variable "app_image" {
  type = string
}

variable "replicas" {
  type = number
}

variable "container_port" {
  type = number
}

variable "service_port" {
  type = number
}
