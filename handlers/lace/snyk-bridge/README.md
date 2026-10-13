# Snyk SAST Bridge

Reads the Run plan diff and queries Snyk's REST API for findings. Produces
the Verdict `block` when any open finding meets or exceeds the configured
severity threshold; `allow` otherwise.

## Configuration

- `snykOrgId` (required) — your Snyk organization ID.
- `severityThreshold` (default `high`) — block on findings at this level
  or above. One of `low | medium | high | critical`.
- `ignoreRules` — Snyk issue IDs to filter out before threshold check.
- `projectIds` — explicit Snyk project IDs to query. When empty, the
  handler walks the plan diff's `snykProjectRefs` annotation.

## Hooks

- `post_plan` — canonical block point for SAST gating.
- `pre_apply` — re-scan after policy approvals before final apply.
