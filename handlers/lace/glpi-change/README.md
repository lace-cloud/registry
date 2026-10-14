# GLPI Change

Keeps each change request in its scope as a GLPI Change. Lace opens the Change
with the change request, writes every approval action taken in Lace to it as a
validation its service user answers naming the person, reads its status and
validations back whenever it reads the change request, and closes it when the
Run ends: Closed when the apply succeeds or fails, with a followup saying which
and for whom, and Cancelled when the Run is cancelled.

## Modes

- **Gating** — the Change's validation decides this Binding's requirement on the
  change request. GLPI holds no per-person credential, so an approver answers it
  in GLPI.
- **Observing** — the Change follows the change request and holds no Run.

## Configuration

- `externalSystemId` — the GLPI external system the Change is opened on. It
  takes no config beyond its credential.
- `externalTemplate` — the text the Change's content opens with.
- `fieldOverrides` — values for the Change's own fields. The name and content
  are Lace's.

## Hooks

- `pre_apply`.
