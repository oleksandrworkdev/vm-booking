data "aws_region" "current" {}

locals {
  region          = data.aws_region.current.name
  service_account = "cloudwatch-agent"
  namespace       = "amazon-cloudwatch"
}

module "cloud_watch_role" {
  source                    = "../service-account-role"
  namespace                 = local.namespace
  service_account           = local.service_account
  created_by                = var.created_by
  cluster_oidc_provider_url = var.cluster_oidc_provider_url
  cluster_oidc_provider_arn = var.cluster_oidc_provider_arn
  policy_arns               = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
}

resource "helm_release" "cloud_watch" {
  name      = "cloud-watch"
  chart     = "${path.module}/chart"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = local.service_account
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cloud_watch_role.role_arn
    type  = "string"
  }

  set {
    name  = "region"
    value = local.region
  }
}
