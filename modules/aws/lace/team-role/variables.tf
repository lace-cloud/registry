variable "boundary_arn" {
  description = "Derived by Lace. The permissions boundary created when an org admin connected the account. Both roles carry it, so no policy grants past the account's ceiling."
  type        = string
}
variable "chaos" {
  description = "Whether the role has a chaos role, <name>-chaos, and what it runs: none; tags, Lace's tag faults; or fis, tag faults and AWS FIS experiments. A chaos experiment acts under the chaos role, never the team's role."
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "tags", "fis"], var.chaos)
    error_message = "chaos must be none, tags or fis."
  }
}
variable "chaos_actions" {
  description = "Derived by Lace. The calls Lace's tag faults make, which the chaos role's lace-chaos-actuation policy grants on *."
  type        = list(string)
}
variable "chaos_fis_actions" {
  description = "Derived by Lace. What the chaos role's lace-chaos-fis policy grants when chaos is fis: experiment, the AWS FIS calls on the account's experiment templates and experiments; unscoped, the calls AWS authorizes only on *; service_linked_role, the call AWS asks of the caller of an account's first experiment, to create AWSServiceRoleForFIS."
  type = object({
    experiment          = list(string)
    unscoped            = list(string)
    service_linked_role = list(string)
  })
}
variable "issuer_host" {
  description = "Derived by Lace. The organization's Lace OIDC issuer without its scheme, which prefixes the trust's aud and sub condition keys."
  type        = string
}
variable "name" {
  description = "The name of the team's role in IAM. The chaos role is <name>-chaos."
  type        = string
}
variable "oidc_audiences" {
  description = "Derived by Lace. The audiences a Lace token for this role carries."
  type        = list(string)
}
variable "oidc_provider_arn" {
  description = "Derived by Lace. The IAM OIDC provider for the organization's Lace issuer in this account."
  type        = string
}
variable "org_id" {
  description = "Derived by Lace. The Lace organization the team belongs to."
  type        = string
}
variable "policy_arns" {
  description = "The IAM policy ARNs attached to the role: the preset's, or your own when the preset is custom."
  type        = list(string)
  default     = []
}
variable "policy_preset" {
  description = "The permission preset you picked in Lace. Lace resolves it to policy_arns and holds both inside the account's ceiling; the role receives policy_arns."
  type        = string
}
variable "team_id" {
  description = "Derived by Lace. The Lace team that owns the role: its path is /lace/team/<team_id>/, and only this team's Lace tokens may assume it."
  type        = string
}
