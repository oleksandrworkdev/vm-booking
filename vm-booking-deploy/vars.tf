variable "aws_region" {
  type        = string
  description = "The name of the region."
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC."
}

variable "vpc_cidr_block" {
  type        = string
  description = "must be a valid IP CIDR range of the form x.x.x.x/x."
}

variable "vpc_subnet_newbits" {
  type        = number
  default     = 2
  description = "The the number of additional bits with which to extend the prefix."
}

variable "vpc_created_by" {
  type        = string
  description = "The identifier of a deployer."
}

variable "vba_created_by" {
  type        = string
  description = "The identifier of a deployer."
}

variable "vba_app_port" {
  type        = string
  description = "The port which application listens to."
}

variable "vba_app_instance_type" {
  type        = string
  description = "The app instance type."
}

variable "vba_db_instance_type" {
  type        = string
  description = "The db instance type."
}

variable "vba_db_instance_storage_size" {
  type        = number
  description = "The db instance storage size."
}

variable "vba_db_replica_instance_type" {
  type        = string
  description = "The db replica instance type."
}

variable "vba_app_version" {
  type        = string
  description = "The app version."
}

variable "vba_app_image" {
  type = string
}

variable "vba_app_lb_certificate_arn" {
  type = string
}

variable "vba_app_cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "vba_app_node_group_size" {
  type        = string
  description = "Node group size"
}

variable "vba_app_replicas" {
  type        = number
  description = "App replicas"
}

variable "vba_app_host" {
  type = string
}