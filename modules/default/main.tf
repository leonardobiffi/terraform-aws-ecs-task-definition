module "task_definition" {
  source = "../.."

  type             = "default"
  execution_role   = var.execution_role
  image            = var.image
  image_tag        = var.image_tag
  log_group        = var.log_group
  name             = var.name
  ports            = var.ports
  task_role        = var.task_role
  cpu              = var.cpu
  memory           = var.memory
  launch_type      = var.launch_type
  network_mode     = var.network_mode
  namespace        = var.namespace
  tasks_desired    = var.tasks_desired
  task_environment = var.task_environment
  task_secrets     = var.task_secrets
  health_check     = var.health_check
  volumes          = var.volumes
  efs_volumes      = var.efs_volumes
  mounts           = var.mounts
}