variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "Managed node group instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}
variable "node_max_size" {
  type    = number
  default = 3
}

# App inputs
variable "app_namespace" {
  type    = string
  default = "app"
}
variable "app_name" {
  type    = string
  default = "demo"
}

variable "app_image" {
  type    = string
  default = "nginx:1.27-alpine"
}

variable "replicas" {
  type    = number
  default = 2
}

variable "container_port" {
  type    = number
  default = 80
}

variable "service_port" {
  type    = number
  default = 80
}

# Key toggle to avoid "couldn't find EKS cluster" during plan on first run
variable "deploy_app" {
  description = "If false, only creates VPC+EKS. If true, also deploys the Kubernetes service"
  type        = bool
  default     = true
}
