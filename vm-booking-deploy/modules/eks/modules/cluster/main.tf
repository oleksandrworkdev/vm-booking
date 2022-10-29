terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.2"
    }
  }
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]

  tags = {
    CreatedBy = var.created_by
  }
}

resource "aws_cloudwatch_log_group" "eks_log_group" {
  name              = "/aws/eks/cluster/cluster"
  retention_in_days = 7

  tags = {
    CreatedBy = var.created_by
  }
}

data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}




resource "kubectl_manifest" "auth" {
  yaml_body = <<YAML
apiVersion: v1
data:
  mapRoles: |
    - groups: 
        - system:bootstrappers
        - system:nodes
      rolearn: ${aws_iam_role.eks_node_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
        - system:masters
      rolearn: arn:aws:iam::551047323477:role/AWSReservedSSO_Global_Admin_Access_0fbd01edc9bcb415
      username: admin-user
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
YAML
}

data "tls_certificate" "cluster_tls_certificate" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}



data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.cluster_oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
  name               = "${var.cluster_name}-vpc-cni-role"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]

  tags = {
    CreatedBy = var.created_by
  }
}



data "aws_iam_policy_document" "node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = data.aws_iam_policy_document.node_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = {
    CreatedBy = var.created_by
  }
}



resource "aws_eks_cluster" "cluster" {
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit"]

  vpc_config {
    subnet_ids = var.private_subnets
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnets

  scaling_config {
    desired_size = var.node_group_size
    max_size     = 10
    min_size     = 1
  }
}
resource "aws_iam_openid_connect_provider" "cluster_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_tls_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_eks_addon" "vpc-cni-addon" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "vpc-cni"

  service_account_role_arn = aws_iam_role.service_account_role.arn
}