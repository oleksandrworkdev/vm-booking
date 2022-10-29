# VMs Booking App
module "db" {
  source     = "./modules/db"
  vpc_id     = var.vpc_id
  subnets    = var.vpc_private_az
  created_by = var.vba_created_by

  db_instance_type         = var.vba_db_instance_type
  db_instance_storage_size = var.vba_db_instance_storage_size
  db_replica_instance_type = var.vba_db_replica_instance_type

  ec2_sg_id = var.vba_app_ec2_sg_id
}

module "eks" {
  source = "./modules/eks"

  cluster_name = var.vba_app_cluster_name
  image        = var.vba_app_image
  app_port     = var.vba_app_port

  db_host     = module.db.db_host
  db_username = module.db.db_username
  db_password = module.db.db_password

  app_version  = var.vba_app_version
  app_replicas = var.vba_app_replicas
  app_host     = var.vba_app_host

  lb_certificate_arn = var.vba_app_lb_certificate_arn

  created_by = var.vba_created_by

  depends_on = [
    module.db
  ]
}
