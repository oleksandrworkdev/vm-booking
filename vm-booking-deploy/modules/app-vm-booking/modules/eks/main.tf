locals {
  app_label           = "vb-app"
  app_ns              = "${local.app_label}-ns"
  app_deploy_name     = "${local.app_label}-deployment"
  app_service_name    = "${local.app_label}-service"
  app_config_map_name = "${local.app_label}-config"
  app_secret_name     = "${local.app_label}-secret"
  app_ingress_name    = "${local.app_label}-ingress"
  app_host            = var.app_host
}

resource "helm_release" "vm_booking" {
  name  = "vm-booking"
  chart = "${path.module}/chart"

  set {
    name  = "app.host"
    value = local.app_host
  }

  set {
    name  = "app.certificateArn"
    value = var.lb_certificate_arn
  }

  set {
    name  = "app.createdBy"
    value = var.created_by
  }

  set {
    name  = "app.ingressName"
    value = local.app_ingress_name
  }

  set {
    name  = "app.image"
    value = var.image
  }

  set {
    name  = "app.replicas"
    value = var.app_replicas
  }

  set {
    name  = "app.deployName"
    value = local.app_deploy_name
  }

  set {
    name  = "app.port"
    value = var.app_port
  }

  set {
    name  = "app.label"
    value = local.app_label
  }

  set {
    name  = "app.serviceName"
    value = local.app_service_name
  }

  set {
    name  = "app.version"
    value = var.app_version
  }

  set {
    name  = "app.configMapName"
    value = local.app_config_map_name
  }

  set {
    name  = "app.namespace"
    value = local.app_ns
  }

  set {
    name  = "app.secretName"
    value = local.app_secret_name
  }

  set_sensitive {
    name  = "app.dbHost"
    value = base64encode(var.db_host)
  }

  set_sensitive {
    name  = "app.dbUsername"
    value = base64encode(var.db_username)
  }

  set_sensitive {
    name  = "app.dbPassword"
    value = base64encode(var.db_password)
  }
}
