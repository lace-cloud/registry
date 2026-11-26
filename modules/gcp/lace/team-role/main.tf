module "this" {
  source          = "./this"
  executor_member = var.executor_member
  name            = var.name
  observer_roles  = var.observer_roles
  planner_member  = var.planner_member
  planner_roles   = var.planner_roles
  project_id      = var.project_id
  roles           = var.roles
  team_id         = var.team_id
}
