# AWS Team Role

A Lace team's AWS IAM role, in an account an org admin connected to Lace.

Lace runs this module as the team's role Stack. A team admin creates the role
from **New connection › AWS**. Lace plans the Stack on Lace's Runner and, once
any approval passes, applies it with the role the account's Lace stack created.
The team's connection then uses `role_arn`. **Change permissions** on the
connection page starts a new Run on the same Stack, and **Destroy the role**,
after disconnecting, starts a destroy Run.

## What it creates

- **The team's role**, named `name`, at the path `/lace/team/<team_id>/`, with
  `boundary_arn` as its permissions boundary. Whatever its policies grant, the
  boundary holds the role inside the ceiling the org admin chose for the
  account.
- **Its trust.** The role trusts only the organization's Lace OIDC provider
  (`oidc_provider_arn`), for `sts:AssumeRoleWithWebIdentity`:
  - `<issuer_host>:aud` must be one of `oidc_audiences`;
  - `<issuer_host>:sub` must match `org:<org_id>:team:<team_id>:*`, so only
    this team's Lace tokens can assume it.
- **One policy attachment for each ARN in `policy_arns`.**
- **An inline policy `lace-observatory`**, granting `observatory_actions`, when
  `observatory` is `basic` or `advanced`.
- **A chaos role** when `chaos` is true, named `<name>-chaos`. It has the same
  path, boundary and trust, and an inline policy `lace-chaos-actuation`
  granting `chaos_actions` and nothing else. A chaos experiment acts under this
  role, so its reach is never the team's role's.

## Inputs

You set these five when you create the role or change its permissions:

| Variable | Type | Default | What it does |
|---|---|---|---|
| `name` | string | | The role's name in IAM. |
| `policy_preset` | string | | The permission preset you picked. Lace resolves it to `policy_arns`; with `custom`, `policy_arns` are your own. |
| `policy_arns` | list(string) | `[]` | The IAM policy ARNs attached to the role. |
| `observatory` | string | `"none"` | `none`, `basic` or `advanced`. |
| `chaos` | bool | `false` | Whether to create the chaos role. |

Lace offers only the presets inside the account's ceiling. Whatever
`policy_arns` grant, the boundary holds the role inside it.

The variables whose description starts "Derived by Lace" are set by Lace from
the organization, the team and the account's Lace stack. Lace refuses a Stack
that sets one:

| Variable | What Lace sets |
|---|---|
| `org_id`, `team_id` | The organization and the team the role belongs to. |
| `oidc_provider_arn` | The account's IAM OIDC provider for the organization's issuer. |
| `issuer_host` | The organization's issuer, without its scheme. |
| `oidc_audiences` | The audiences a Lace token for the role carries. |
| `boundary_arn` | The permissions boundary the account's Lace stack created. |
| `observatory_actions` | The read-only actions Lace's scanners call at the chosen tier. |
| `chaos_actions` | The actions Lace's chaos experiments call. |

## Outputs

| Output | Value |
|---|---|
| `role_arn` | The ARN of the team's role. |
| `chaos_role_arn` | The ARN of the chaos role, or null when `chaos` is false. |
