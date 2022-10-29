resource "random_string" "random_policy_name" {
  length  = 2
  special = false
  upper   = false
  number  = false
}

locals {
  policy_path_exist = var.policy_path != ""
}

resource "aws_iam_policy" "policy" {
  count  = local.policy_path_exist ? 1 : 0
  name   = "${var.service_account}-policy-${random_string.random_policy_name.result}"
  policy = file("${var.policy_path}")

  tags = {
    CreatedBy = var.created_by
  }
}

locals {
  cluster_oidc_provider_uri = replace(var.cluster_oidc_provider_url, "https://", "")
  cluster_oidc_provider_arn = var.cluster_oidc_provider_arn
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.cluster_oidc_provider_uri}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
    }

    principals {
      identifiers = [local.cluster_oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "random_string" "random_role_name" {
  length  = 2
  special = false
  upper   = false
  number  = false
}

resource "aws_iam_role" "role" {
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  name               = "${var.service_account}-role-${random_string.random_role_name.result}"

  managed_policy_arns = local.policy_path_exist ? concat([aws_iam_policy.policy[0].arn], var.policy_arns) : var.policy_arns

  tags = {
    CreatedBy = var.created_by
  }
}
