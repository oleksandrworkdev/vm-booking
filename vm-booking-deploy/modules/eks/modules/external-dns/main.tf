locals {
  namespace       = "default"
  service_account = "external-dns"
}

module "external_dns_role" {
  source                    = "../service-account-role"
  namespace                 = "default"
  service_account           = "external-dns"
  created_by                = var.created_by
  cluster_oidc_provider_url = var.cluster_oidc_provider_url
  cluster_oidc_provider_arn = var.cluster_oidc_provider_arn
  policy_path               = "${path.module}/external-dns-policy.json"
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "5.2.2"
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
    value = module.external_dns_role.role_arn
    type  = "string"
  }

  set {
    name  = "domainFilters[0]"
    value = var.hosted_zone
  }

  set {
    name  = "policy"
    value = "sync"
  }
}
