output "chaos_role_actions" {
  value = var.chaos == "none" ? null : distinct(flatten([
    for policy in concat(aws_iam_role_policy.chaos, aws_iam_role_policy.chaos_fis) : [
      for statement in jsondecode(policy.policy).Statement : statement.Action
    ]
  ]))
}
output "chaos_role_arn" {
  value = one(aws_iam_role.chaos[*].arn)
}
output "role_arn" {
  value = aws_iam_role.this.arn
}
