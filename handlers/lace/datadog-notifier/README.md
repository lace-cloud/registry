# Datadog Run Notifier

Posts a Datadog event with the Run summary after each Run completes.
Always records the Verdict `allow`, with a message saying what it posted (or why it skipped) — never gates Run progression.

## Configuration

- `site` (default `us1`) — Datadog region. One of `us1 | us3 | us5 | eu1 | us1-fed`.
- `tags` — static tags appended to every event.
- `alertOnFailure` (default `true`) — when true, Runs that terminate as
  `apply_failed` produce events at `alert_type=error` instead of `info`.

## Hooks

- `post_apply` — fire after an apply or destroy Run reaches a terminal state
  (`apply_succeeded` / `apply_failed`). Filter on `run.kind` to observe only one.
