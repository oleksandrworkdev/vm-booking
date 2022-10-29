terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.49.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.2.0"
    }
  }

  backend "s3" {
    bucket         = "oonyshchenko-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "oonyshchenko-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.aws_region
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.aws_region
      ]
      command = "aws"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name           = var.vpc_name
  vpc_cidr_block     = var.vpc_cidr_block
  vpc_subnet_newbits = var.vpc_subnet_newbits
  vpc_created_by     = var.vpc_created_by

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.vba_app_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                   = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.vba_app_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                            = "1"
  }
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.vba_app_cluster_name

  public_subnets  = [module.vpc.vpc_public_az_1, module.vpc.vpc_public_az_2]
  private_subnets = [module.vpc.vpc_private_az_1, module.vpc.vpc_private_az_2]
  created_by      = var.vpc_created_by
  node_group_size = var.vba_app_node_group_size
  app_host        = var.vba_app_host
}

module "app_vm_booking" {
  source = "./modules/app-vm-booking"

  vpc_id         = module.vpc.vpc_id
  vpc_public_az  = [module.vpc.vpc_public_az_1, module.vpc.vpc_public_az_2]
  vpc_private_az = [module.vpc.vpc_private_az_1, module.vpc.vpc_private_az_2]

  vba_db_instance_type         = var.vba_db_instance_type
  vba_db_instance_storage_size = var.vba_db_instance_storage_size
  vba_db_replica_instance_type = var.vba_db_replica_instance_type

  vba_app_version  = var.vba_app_version
  vba_app_image    = var.vba_app_image
  vba_app_replicas = var.vba_app_replicas
  vba_created_by   = var.vba_created_by
  vba_app_port     = var.vba_app_port

  vba_app_cluster_name = var.vba_app_cluster_name
  vba_app_ec2_sg_id    = module.eks.cluster_sg_id

  vba_app_lb_certificate_arn = var.vba_app_lb_certificate_arn
  vba_app_host               = var.vba_app_host
}
