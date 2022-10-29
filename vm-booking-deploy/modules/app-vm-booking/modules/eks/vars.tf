variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "image" {
  type        = string
  description = "ECR image label"
}

variable "app_port" {
  type        = number
  description = "App port"
}

variable "db_username" {
  type        = string
  description = "DB username"
}

variable "db_password" {
  type        = string
  description = "DB password"
}

variable "db_host" {
  type        = string
  description = "DB host"
}

variable "app_version" {
  type        = string
  description = "App Version"
}

variable "app_replicas" {
  type        = number
  description = "App replicas"
}

variable "lb_certificate_arn" {
  type        = string
  description = "Certificate ARN"
}

variable "created_by" {
  type        = string
  description = "The identifier of a deployer."
}

variable "app_host" {
  type = string
}
