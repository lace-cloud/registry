# Drift Detection

Compares each Stack's live resources with the Stack as of its last successful
apply, and reports every resource that differs as a drift finding. One Scanner
serves Stacks on every cloud: a scan plans the Stack's whole Terraform, so it
compares every resource the Stack manages, whichever provider manages it.

Every organization installs it when it is set up. Each Stack it scans is bound
to it by its own Binding: every live Stack, AWS or GCP. A Stack is scanned on
its Binding's cadence, every four hours by default, after each apply, and when
someone asks for a scan.

Each scan writes:

- a `drift-event` finding per drifted resource, with what differs, its
  severity, and where the resource lives;
- a `drift.summary` snapshot of the Stack's scan;
- the Stack's resources as inventory.

A finding's resource lives where the Terraform provider that manages it says:
`aws` for an `aws_s3_bucket`, `gcp` for a `google_storage_bucket`,
`cloudflare` for a `cloudflare_record`, `azure` for an `azurerm_*` resource.
A resource of any other provider lives where that provider is named, such as
`github` or `random`. The snapshot and the inventory carry the cloud of the
Stack's connection, the cloud the scan reads through.

## Who changed it

Each drifted resource names who made the latest change to it, and when: the
newest write to the resource, since the Run that last applied the Stack, that
this Stack's own Runs did not make. A scan holds one credential, the Stack's
connection, so it reads the record of calls of that connection's cloud:

- On AWS, the account's CloudTrail event history, read with the connection's
  role, which must allow `cloudtrail:LookupEvents`. Lace's Admin, Power user
  and Read-only presets allow it. A write made through assumed roles is
  followed back to the session it came from. A Stack that connects through its
  account's anchor names no one: the anchor can't read CloudTrail.
- On GCP, the project's Admin Activity audit log, read as the connection's
  execution service account, with an access token whose only scope is reading
  logs. The Terraform Lace generates for a GCP connection grants that account
  `roles/logging.viewer` on the project; a connection made without it names no
  one and says Lace may not read the project's audit logs. Admin Activity logs
  are always on, whatever the project's logging settings.

A drifted resource that lives outside the cloud of the Stack's connection,
such as a `google_storage_bucket` in a Stack that connects to AWS, names no
one, and says so.

## Configuration

`driftSeverityRules` classifies each drifted resource's severity: a rule
matches on resource types, resource categories, Stacks or connections, and the
matching rule with the highest `priority` sets `critical`, `warning` or `info`.
One rule set covers every Stack, so one rule may name resource types of
several clouds. The install starts with two rules: identity drift is critical,
and network-perimeter drift is a warning. An org admin edits them on the
portal's Drift severity page.
