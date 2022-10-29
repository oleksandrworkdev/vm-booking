locals {
  service_account = "aws-load-balancer-controller"
  namespace       = "kube-system"
}

module "aws_lb_controller_role" {
  source                    = "../service-account-role"
  namespace                 = local.namespace
  service_account           = local.service_account
  created_by                = var.created_by
  cluster_oidc_provider_url = var.cluster_oidc_provider_url
  cluster_oidc_provider_arn = var.cluster_oidc_provider_arn
  policy_path               = "${path.module}/aws-lb-controller-policy.json"
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.2.3"
  namespace  = local.namespace

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
    value = module.aws_lb_controller_role.role_arn
    type  = "string"
  }
}
