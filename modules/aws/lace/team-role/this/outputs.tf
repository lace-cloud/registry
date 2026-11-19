output "chaos_role_arn" {
  value = one(aws_iam_role.chaos[*].arn)
}
output "role_arn" {
  value = aws_iam_role.this.arn
}
