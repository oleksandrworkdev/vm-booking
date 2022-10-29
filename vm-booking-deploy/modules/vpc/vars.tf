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

variable "public_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "private_subnet_tags" {
  type    = map(any)
  default = {}
}
