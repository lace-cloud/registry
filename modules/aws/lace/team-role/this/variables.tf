variable "boundary_arn" {
  type = string
}
variable "chaos" {
  type = bool
}
variable "chaos_actions" {
  type = list(string)
}
variable "issuer_host" {
  type = string
}
variable "name" {
  type = string
}
variable "observatory" {
  type = string
}
variable "observatory_actions" {
  type = list(string)
}
variable "oidc_audiences" {
  type = list(string)
}
variable "oidc_provider_arn" {
  type = string
}
variable "org_id" {
  type = string
}
variable "policy_arns" {
  type = list(string)
}
variable "team_id" {
  type = string
}
