# Jira Service Management Change

Keeps each change request in its scope as a Jira Service Management
service-desk request. Lace raises the request with the change request, writes
every approval action taken in Lace to it, reads its status and approvals back whenever it reads the change request, and closes it
when the Run ends, by the request's own transition: to a done status such as
Resolved when the apply succeeds, to Failed when it fails, and to Canceled when
the Run is cancelled.

## Modes

- **Gating** — the request's approval decides this Binding's requirement on the
  change request, under JSM's own approval rule. An approver answers it in JSM,
  or in Lace through their own connected Atlassian account. Every other
  approval action in Lace is written to the request as a comment naming the
  person, which decides nothing.
- **Observing** — the request follows the change request and holds no Run. Every
  approval action in Lace is written to it as the acting person's answer.

## Configuration

- `externalSystemId` — the JSM external system the request is raised on. Its
  config names `projectKey`, the service desk's project, and `requestTypeId`,
  the request type every request is raised as; the system's settings list the
  service desk's request types.
- `externalTemplate` — the text the request's description opens with.
- `fieldOverrides` — values for the request type's own fields. The summary and
  description are Lace's.

## Hooks

- `pre_apply`.
