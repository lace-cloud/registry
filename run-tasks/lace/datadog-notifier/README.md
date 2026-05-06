# lace/datadog-notifier

Posts a Datadog event with the Lace Run summary after each Run completes.
Always returns an `advisory` verdict — never gates Run progression.

## Configuration

- `site` (default `us1`) — Datadog region. One of `us1 | us3 | us5 | eu1 | us1-fed`.
  Maps to the Datadog Events API host:
    - `us1` → `https://api.datadoghq.com`
    - `us3` → `https://api.us3.datadoghq.com`
    - `us5` → `https://api.us5.datadoghq.com`
    - `eu1` → `https://api.datadoghq.eu`
    - `us1-fed` → `https://api.ddog-gov.com`
- `tags` — static tags appended to every event. Format: `key:value`,
  one tag per array entry. Common usage: `["team:platform", "service:terraform"]`.
- `alertOnFailure` (default `true`) — when true, Runs that terminate
  as `apply_failed` produce events at `alert_type=error` instead of
  `alert_type=info`. Other Run statuses are always `info`.

## API key

Provide a Datadog API key with `events_write` scope at install time.
The key is envelope-encrypted on the install row and never logged.

## Hooks

- `post_apply` — fire after Run terminal `apply_succeeded` /
  `apply_failed`.
- `post_destroy` — fire after Run terminal `apply_succeeded` for
  destroy-kind Runs.

## What gets sent to Datadog

Each event carries:

- `title`: `Lace Run <id> <status> on <stack name>`
- `text`: hook, run id, stack, status (one per line)
- `tags`: configured tags + `lace_hook:<hook>` + `lace_status:<runStatus>`
- `alert_type`: `error` for failed Runs (when `alertOnFailure=true`)
  or `info` otherwise
- `source_type_name`: `lace`

## Verdict semantics

Always `advisory`. Never blocks the Run. The handler returns
`advisory` even on Datadog errors (rate limit, transient outage)
because notifications are best-effort.

## Rate limits

Datadog Events API has per-org volume caps. Refer to your Datadog
contract for exact limits. The handler does not retry on 429 — it
returns `advisory` with a status code message and continues.
