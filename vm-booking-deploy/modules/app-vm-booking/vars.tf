variable "vpc_id" {
  type = string
}

variable "vba_created_by" {
  type        = string
  description = "The identifier of a deployer."
}

variable "vba_app_port" {
  type        = string
  description = "The port which application listens to."
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

variable "vpc_public_az" {
  type        = list(string)
  description = "The list of public subnets."
}

variable "vpc_private_az" {
  type        = list(string)
  description = "The list of public subnets."
}

variable "vba_app_image" {
  type = string
}

variable "vba_app_cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "vba_app_ec2_sg_id" {
  type        = string
  description = "ID of EC2 sg"
}

variable "vba_app_replicas" {
  type        = number
  description = "App replicas"
}

variable "vba_app_lb_certificate_arn" {
  type        = string
  description = "Certificate arn"
}

variable "vba_app_host" {
  type = string
}