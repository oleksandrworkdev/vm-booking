module "cluster" {
  source          = "./modules/cluster"
  cluster_name    = var.cluster_name
  created_by      = var.created_by
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  node_group_size = var.node_group_size
}

module "dns" {
  source       = "./modules/dns"
  cluster_name = module.cluster.cluster_name
  app_host     = var.app_host
}

module "aws_lb_controller" {
  source                    = "./modules/aws-lb-controller"
  created_by                = var.created_by
  cluster_oidc_provider_url = module.cluster.cluster_oidc_provider_url
  cluster_oidc_provider_arn = module.cluster.cluster_oidc_provider_arn
  cluster_name              = module.cluster.cluster_name
}

module "external_dns" {
  source                    = "./modules/external-dns"
  created_by                = var.created_by
  cluster_oidc_provider_url = module.cluster.cluster_oidc_provider_url
  cluster_oidc_provider_arn = module.cluster.cluster_oidc_provider_arn
  cluster_name              = module.cluster.cluster_name
  hosted_zone               = module.dns.hosted_zone
}

module "cloud_watch" {
  source                    = "./modules/cloud-watch"
  created_by                = var.created_by
  cluster_oidc_provider_url = module.cluster.cluster_oidc_provider_url
  cluster_oidc_provider_arn = module.cluster.cluster_oidc_provider_arn
  cluster_name              = module.cluster.cluster_name
}

module "prometheus" {
  source = "./modules/prometheus"
}
