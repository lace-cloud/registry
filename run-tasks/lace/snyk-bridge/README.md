# lace/snyk-bridge

Reads the Run plan diff and queries Snyk's REST API for findings.
Produces a `failed` verdict when any open finding meets or exceeds
the configured severity threshold; `passed` otherwise.

## Configuration

- `snykOrgId` (required) — your Snyk organization ID. Find it in the
  Snyk web UI under **Settings → General**.
- `severityThreshold` (default `high`) — block on findings at this
  level or above. One of `low | medium | high | critical`.
- `ignoreRules` — Snyk issue IDs (e.g. `SNYK-JS-LODASH-1234`) to filter
  out before the threshold check. Useful for exceptions you've already
  triaged.
- `projectIds` — explicit Snyk project IDs to query. When empty, the
  handler walks the plan diff's `snykProjectRefs` annotation if the
  customer's IaC pipeline supplies one.
- `apiHost` (default `https://api.snyk.io`) — Snyk REST host. Override
  for self-hosted Snyk deployments or regional endpoints.

## API key

Provide a Snyk API key with read access to issues at install time.
The key is envelope-encrypted on the install row and never logged.

## Hooks

- `post_plan` — canonical block point for SAST gating. Fires after
  Lace records the plan-diff but before policy resolution gates the Run.
- `pre_apply` — re-scan after policy approvals before the final apply
  step. Useful when long-lived plan-diffs may have stale Snyk findings.

## What gets sent to Snyk

The handler issues one `GET /rest/orgs/:orgId/issues` per dispatch. No
plan-diff content is forwarded; only the Snyk org ID + project IDs.

## Verdict semantics

- `passed` — zero findings at or above `severityThreshold`.
- `failed` — at least one finding at or above the threshold (after
  applying `ignoreRules`). Blocks the Run when bound `mandatory`.
- `dispatch_failed` — Snyk returned non-2xx (rate limit, auth failure,
  outage). Blocks the Run when bound `mandatory`; advisory bindings
  let the Run continue.

## Rate limits

Snyk's REST API has per-org rate limits. The handler returns
`dispatch_failed` with the `Retry-After` value embedded in the verdict
message so operators can re-trigger the Run after the window passes.
