data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
locals {
  path = "/lace/team/${var.team_id}/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Federated = var.oidc_provider_arn }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = { "${var.issuer_host}:aud" = var.oidc_audiences }
          StringLike   = { "${var.issuer_host}:sub" = "org:${var.org_id}:team:${var.team_id}:*" }
        }
      },
    ]
  })
  fis_resources = [
    "arn:${data.aws_partition.current.partition}:fis:*:${data.aws_caller_identity.current.account_id}:experiment-template/*",
    "arn:${data.aws_partition.current.partition}:fis:*:${data.aws_caller_identity.current.account_id}:experiment/*",
  ]
}
resource "aws_iam_role" "this" {
  assume_role_policy   = local.assume_role_policy
  name                 = var.name
  path                 = local.path
  permissions_boundary = var.boundary_arn
}
resource "aws_iam_role_policy_attachment" "this" {
  for_each   = toset(var.policy_arns)
  policy_arn = each.value
  role       = aws_iam_role.this.name
}
resource "aws_iam_role_policy" "observatory" {
  count = var.observatory != "none" ? 1 : 0
  name  = "lace-observatory"
  role  = aws_iam_role.this.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ObservatoryRead"
        Effect   = "Allow"
        Action   = var.observatory_actions
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_role" "chaos" {
  count                = var.chaos != "none" ? 1 : 0
  assume_role_policy   = local.assume_role_policy
  name                 = "${var.name}-chaos"
  path                 = local.path
  permissions_boundary = var.boundary_arn
}
resource "aws_iam_role_policy" "chaos" {
  count = var.chaos != "none" ? 1 : 0
  name  = "lace-chaos-actuation"
  role  = aws_iam_role.chaos[0].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ChaosActuation"
        Effect   = "Allow"
        Action   = var.chaos_actions
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_role_policy" "chaos_fis" {
  count = var.chaos == "fis" ? 1 : 0
  name  = "lace-chaos-fis"
  role  = aws_iam_role.chaos[0].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "FisExperiments"
        Effect   = "Allow"
        Action   = var.chaos_fis_actions.experiment
        Resource = local.fis_resources
      },
      {
        Sid      = "FisList"
        Effect   = "Allow"
        Action   = var.chaos_fis_actions.unscoped
        Resource = "*"
      },
      {
        Sid       = "FisServiceLinkedRole"
        Effect    = "Allow"
        Action    = var.chaos_fis_actions.service_linked_role
        Resource  = "*"
        Condition = { StringEquals = { "iam:AWSServiceName" = "fis.amazonaws.com" } }
      },
    ]
  })
}
