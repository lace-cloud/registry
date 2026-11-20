output "chaos_role_actions" {
  description = "The actions the chaos role's policies grant, or null when chaos is none"
  value       = module.this.chaos_role_actions
}
output "chaos_role_arn" {
  description = "The ARN of the chaos role, or null when chaos is none"
  value       = module.this.chaos_role_arn
}
output "role_arn" {
  description = "The ARN of the team's role"
  value       = module.this.role_arn
}
