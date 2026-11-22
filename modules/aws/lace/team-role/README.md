# AWS Team Role

A Lace team's AWS IAM role, in an account an org admin connected to Lace.

Lace runs this module as the team's role Stack. A team admin creates the role
from **New connection › AWS**. A Runner plans the Stack and, once any approval
passes, applies it with the role an org admin created in the account with
**Connect an AWS account**, by applying the Terraform Lace generates for it. The
team's connection then uses `role_arn`. **Change permissions** on the
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
- **A chaos role** when `chaos` is `tags` or `fis`, named `<name>-chaos`, with
  the same path, boundary and trust. Its inline policy `lace-chaos-actuation`
  grants `chaos_actions` on `*`, the calls Lace's tag faults make. With `fis` it
  also has `lace-chaos-fis`: `chaos_fis_actions.experiment` on the account's AWS
  FIS experiment templates and experiments, `chaos_fis_actions.unscoped` on
  `*`, and `chaos_fis_actions.service_linked_role` on `*` for
  `fis.amazonaws.com` only, which AWS asks of the caller of an account's first
  experiment to create `AWSServiceRoleForFIS`. A chaos experiment acts under
  this role, so its reach is never the team's role's. An AWS FIS experiment
  acts with its template's own role, which the template's author passed when
  making it, so this role holds no `iam:PassRole`.

### The chaos role's grants

`chaos` picks one of three grants, each holding the one before:

| `chaos` | Chaos role | Its inline policies | What it runs |
|---|---|---|---|
| `none` | none | | No chaos experiment. |
| `tags` | `<name>-chaos` | `lace-chaos-actuation` | Lace's tag faults. |
| `fis` | `<name>-chaos` | `lace-chaos-actuation`, `lace-chaos-fis` | Tag faults and the account's AWS FIS experiment templates. |

`lace-chaos-fis` has three statements:

| Statement | Actions | Resource |
|---|---|---|
| `FisExperiments` | `chaos_fis_actions.experiment` | `arn:<partition>:fis:*:<account>:experiment-template/*` and `arn:<partition>:fis:*:<account>:experiment/*`, the account's templates and experiments in every region |
| `FisList` | `chaos_fis_actions.unscoped` | `*` |
| `FisServiceLinkedRole` | `chaos_fis_actions.service_linked_role` | `*`, when `iam:AWSServiceName` is `fis.amazonaws.com` |

Why, from AWS's pages:

- **The resources.** AWS authorizes `GetExperimentTemplate` on an experiment
  template, `StartExperiment` on both the template and the experiment, and
  `TagResource`, `GetExperiment` and `StopExperiment` on an experiment.
  `ListExperiments` has no resource type, so it is granted on `*` alone.
  Starting an experiment with tags is also authorized as `fis:TagResource`
  ([Service Authorization Reference: AWS FIS](https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsfaultinjectionservice.html)).
- **No `iam:PassRole`.** AWS checks `iam:PassRole` only when a template is
  created or updated, never when an experiment starts, and FIS's own policy
  for starting an experiment grants none
  ([Service Authorization Reference: AWS FIS](https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsfaultinjectionservice.html),
  [Start an experiment](https://docs.aws.amazon.com/fis/latest/userguide/security_iam_id-based-policy-examples.html#security-iam-policy-examples-start-experiment)).
- **The service-linked role.** When the account's first experiment starts, AWS
  FIS creates `AWSServiceRoleForFIS`, which asks the caller for
  `iam:CreateServiceLinkedRole` with `iam:AWSServiceName` =
  `fis.amazonaws.com`
  ([Using service-linked roles for AWS FIS](https://docs.aws.amazon.com/fis/latest/userguide/using-service-linked-roles.html)).

The boundary holds both policies, as it holds the team's role: under a
Read-only ceiling, Lace offers neither `tags` nor `fis`.

## Inputs

You set these five when you create the role or change its permissions:

| Variable | Type | Default | What it does |
|---|---|---|---|
| `name` | string | | The role's name in IAM. |
| `policy_preset` | string | | The permission preset you picked. Lace resolves it to `policy_arns`; with `custom`, `policy_arns` are your own. |
| `policy_arns` | list(string) | `[]` | The IAM policy ARNs attached to the role. |
| `observatory` | string | `"none"` | `none`, `basic` or `advanced`. |
| `chaos` | string | `"none"` | `none`, `tags` or `fis`. |

Lace offers only the presets inside the account's ceiling. Whatever
`policy_arns` grant, the boundary holds the role inside it.

The variables whose description starts "Derived by Lace" are set by Lace from
the organization, the team and the connected account. Lace refuses a Stack
that sets one:

| Variable | What Lace sets |
|---|---|
| `org_id`, `team_id` | The organization and the team the role belongs to. |
| `oidc_provider_arn` | The account's IAM OIDC provider for the organization's issuer. |
| `issuer_host` | The organization's issuer, without its scheme. |
| `oidc_audiences` | The audiences a Lace token for the role carries. |
| `boundary_arn` | The permissions boundary created when an org admin connected the account. |
| `observatory_actions` | The read-only actions Lace's scanners call at the chosen tier. |
| `chaos_actions` | The calls Lace's tag faults make. |
| `chaos_fis_actions` | What `lace-chaos-fis` grants when `chaos` is `fis`, grouped by the resources AWS authorizes them on: `experiment`, `unscoped` and `service_linked_role`. |

## Outputs

| Output | Value |
|---|---|
| `role_arn` | The ARN of the team's role. |
| `chaos_role_arn` | The ARN of the chaos role, or null when `chaos` is `none`. |
| `chaos_role_actions` | The actions the chaos role's policies grant, read back from the policies applied, or null when `chaos` is `none`. |
