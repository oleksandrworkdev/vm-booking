variable "created_by" {
  type        = string
  description = "The identifier of a deployer."
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC."
}

variable "subnets" {}

variable "db_instance_type" {
  type        = string
  description = "The db instance type."
}

variable "db_instance_storage_size" {
  type        = number
  description = "The db instance storage size."
}

variable "db_replica_instance_type" {
  type        = string
  description = "The db replica instance type."
}

variable "ec2_sg_id" {
  type        = string
  description = "SG ID to allow access from."
}
