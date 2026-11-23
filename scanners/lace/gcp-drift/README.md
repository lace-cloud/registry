# GCP Drift Detection

Compares each GCP Stack's live resources with the Stack as of its last
successful apply, and reports every resource that differs as a drift finding.

Every organization installs it when it is set up. Each Stack it scans is bound
to it by its own Binding: every Stack that deploys into a GCP project. A Stack
is scanned on its Binding's cadence, every four hours by default, after each
apply, and when someone asks for a scan.

Each scan writes:

- a `drift-event` finding per drifted resource, with what differs and its
  severity;
- a `drift.summary` snapshot of the Stack's scan;
- the Stack's resources as inventory.

## Who changed it

Each drifted resource names who made the latest change to it, and when, from
the project's Admin Activity audit log: the newest write to the resource, since
the Run that last applied the Stack, that this Stack's own Runs did not make.
Lace reads it as the connection's execution service account, with an access
token whose only scope is reading logs. The Terraform Lace generates for a GCP
connection grants that account `roles/logging.viewer` on the project; a
connection made without it names no one and says Lace may not read the
project's audit logs. Admin Activity logs are always on, whatever the project's
logging settings.

## Configuration

`driftSeverityRules` classifies each drifted resource's severity: a rule
matches on resource types, resource categories, Stacks or connections, and the
matching rule with the highest `priority` sets `critical`, `warning` or `info`.
The install starts with two rules: identity drift is critical, and
network-perimeter drift is a warning. An org admin edits them on the portal's
Drift severity page.
