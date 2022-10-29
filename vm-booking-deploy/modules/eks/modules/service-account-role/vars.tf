variable "namespace" {
  type = string
}

variable "service_account" {
  type = string
}

variable "created_by" {
  type = string
}

variable "cluster_oidc_provider_url" {
  type = string
}

variable "cluster_oidc_provider_arn" {
  type = string
}

variable "policy_path" {
  type    = string
  default = ""
}

variable "policy_arns" {
  type    = list(string)
  default = []
}
