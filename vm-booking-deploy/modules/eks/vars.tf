variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "created_by" {
  type        = string
  description = "The identifier of a deployer"
}

variable "public_subnets" {
  type        = list(string)
  description = "The list of public subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "The list of private subnets"
}

variable "node_group_size" {
  type        = number
  description = "Node group size"
}

variable "app_host" {
  type = string
}