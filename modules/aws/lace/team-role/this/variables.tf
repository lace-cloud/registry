variable "boundary_arn" {
  type = string
}
variable "chaos" {
  type = string
}
variable "chaos_actions" {
  type = list(string)
}
variable "chaos_fis_actions" {
  type = object({
    experiment          = list(string)
    unscoped            = list(string)
    service_linked_role = list(string)
  })
}
variable "issuer_host" {
  type = string
}
variable "name" {
  type = string
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
