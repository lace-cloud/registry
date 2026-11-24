# GCP Team Role

A Lace team's Google Cloud service accounts, in a project an org admin
connected to Lace.

Only Lace runs this module, as the team's role Stack, and only as the
project's anchor: the access an org admin gave Lace with **Connect a cloud
account › Google Cloud project**, by applying the Terraform Lace generates for
it. A team admin creates the role from **New connection › Google Cloud**. A
Runner plans the Stack and, once an admin of the team or an org admin approves,
never the person who asked, applies it as the anchor. The anchor reaches every
service account in the project, so the Stack's jobs run only on Lace's managed
Runners or on a Runner an org admin registered for the whole organization,
never on a team's own Runner. The team's connection then uses `executor_email`
and `planner_email`. **Change permissions** on the connection page starts a new
Run on the same Stack, and **Destroy the role**, after disconnecting, starts a
destroy Run.

## What it creates

- **The executor**, the service account `<name>@<project_id>.iam.gserviceaccount.com`,
  which the team's Runs apply as:
  - **its trust:** `roles/iam.workloadIdentityUser` on the account, granted to
    `executor_member` alone, the team's executor identity in the
    organization's workload identity pool. Only this team's Lace tokens for its
    executor act as it;
  - **its roles:** each of `roles` and `observer_roles`, granted on the
    project.
- **The planner**, `<name>-plan@<project_id>.iam.gserviceaccount.com`, which a
  plan on a person's machine reads as:
  - **its trust:** `roles/iam.workloadIdentityUser` on the account, granted to
    `planner_member` alone, the team's planner identity in the same pool;
  - **its roles:** each of `planner_roles`, granted on the project. They read
    and never write.

Both accounts' display name is `Lace team role <account id>`, and their
description `lace-team=<team_id>`.

Workload Identity User is the one role the anchor may grant on a service
account, and Google holds it to that. It carries no permission to grant. Every
project role the anchor grants is one of the ceiling's roles or Lace's read
roles, and Google holds that too.

Neither account is ever adopted. If the project already holds a service
account with either ID, Lace refuses the name before it plans, and an apply
that meets one fails.

The module declares no provider block: the Runner's credential for the anchor
names the project that every request bills.

## Inputs

You set these two when you create the role or change its permissions:

| Variable | Type | What it does |
|---|---|---|
| `name` | string | The executor's service account ID in the project. The planner is `<name>-plan`. 6 to 25 lowercase letters, digits or hyphens, starting with a letter and ending with a letter or digit: Google allows 30 characters for an ID, and `-plan` takes five. |
| `roles` | list(string) | The project roles the executor holds. |

Lace offers only the roles in the project's ceiling, and refuses any other.

The variables whose description starts "Derived by Lace" are set by Lace from
the organization, the team and the connected project. Lace refuses a Stack
that sets one:

| Variable | What Lace sets |
|---|---|
| `org_id`, `team_id` | The organization and the team the role belongs to. |
| `project_id` | The Google Cloud project the org admin connected. |
| `executor_member`, `planner_member` | The principal sets of the team's executor and planner identities in the organization's workload identity pool, each the one member its service account trusts. |
| `planner_roles` | The read roles a plan's refresh needs, with a content read (object contents, secret values, decryption) only where one of `roles` carries it. |
| `observer_roles` | The project roles Lace's own reads of the project need. |

## Outputs

| Output | Value |
|---|---|
| `executor_email` | The email of the executor service account. |
| `planner_email` | The email of the planner service account. |
