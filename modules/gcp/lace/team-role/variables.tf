variable "executor_member" {
  description = "Derived by Lace. The principal set of the team's executor identity in the organization's workload identity pool: the one member granted Workload Identity User on the executor service account."
  type        = string
}
variable "name" {
  description = "The executor service account's ID in the project. The planner is <name>-plan."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,23}[a-z0-9]$", var.name))
    error_message = "name must be 6 to 25 lowercase letters, digits or hyphens, starting with a letter."
  }
}
variable "observer_roles" {
  description = "Derived by Lace. The project roles Lace's own reads of the project need, which the executor holds beside roles."
  type        = list(string)
}
variable "org_id" {
  description = "Derived by Lace. The Lace organization the team belongs to."
  type        = string
}
variable "planner_member" {
  description = "Derived by Lace. The principal set of the team's planner identity in the organization's workload identity pool: the one member granted Workload Identity User on the planner service account."
  type        = string
}
variable "planner_roles" {
  description = "Derived by Lace. The read roles the planner holds: the metadata a plan's refresh reads, and a content read only where one of roles carries it."
  type        = list(string)
}
variable "project_id" {
  description = "Derived by Lace. The Google Cloud project an org admin connected, where both service accounts and their roles are made."
  type        = string
}
variable "roles" {
  description = "The project roles the executor holds, each inside the project's ceiling."
  type        = list(string)
}
variable "team_id" {
  description = "Derived by Lace. The Lace team that owns the role: both service accounts' descriptions name it."
  type        = string
}
