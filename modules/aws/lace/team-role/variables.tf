variable "boundary_arn" {
  description = "Derived by Lace. The permissions boundary the account's Lace stack created. Both roles carry it, so no policy grants past the account's ceiling."
  type        = string
}
variable "chaos" {
  description = "Create a second role, <name>-chaos, that holds only chaos_actions, so a chaos experiment acts under its own identity rather than the team's role."
  type        = bool
  default     = false
}
variable "chaos_actions" {
  description = "Derived by Lace. The actions Lace's chaos experiments call, and the chaos role's whole grant."
  type        = list(string)
}
variable "issuer_host" {
  description = "Derived by Lace. The organization's Lace OIDC issuer without its scheme, which prefixes the trust's aud and sub condition keys."
  type        = string
}
variable "name" {
  description = "The name of the team's role in IAM. The chaos role is <name>-chaos."
  type        = string
}
variable "observatory" {
  description = "The Observatory tier the role serves: none, basic or advanced. Any tier but none puts an inline policy granting observatory_actions on the role."
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "basic", "advanced"], var.observatory)
    error_message = "observatory must be none, basic or advanced."
  }
}
variable "observatory_actions" {
  description = "Derived by Lace. The read-only actions Lace's scanners call at the observatory tier."
  type        = list(string)
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
