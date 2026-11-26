output "executor_email" {
  description = "The email of the executor service account, which the team's Runs apply as"
  value       = module.this.executor_email
}
output "planner_email" {
  description = "The email of the planner service account, which a plan on a person's machine reads as"
  value       = module.this.planner_email
}
