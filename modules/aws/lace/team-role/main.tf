module "this" {
  source              = "./this"
  boundary_arn        = var.boundary_arn
  chaos               = var.chaos
  chaos_actions       = var.chaos_actions
  chaos_fis_actions   = var.chaos_fis_actions
  issuer_host         = var.issuer_host
  name                = var.name
  observatory         = var.observatory
  observatory_actions = var.observatory_actions
  oidc_audiences      = var.oidc_audiences
  oidc_provider_arn   = var.oidc_provider_arn
  org_id              = var.org_id
  policy_arns         = var.policy_arns
  team_id             = var.team_id
}
