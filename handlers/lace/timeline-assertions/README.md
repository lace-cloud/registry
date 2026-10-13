# Timeline Assertions

Reads the timeline over a Run's apply window — from its move into `applying`
to its end — and records a Verdict saying whether the window showed what the
Binding asserts. Bind it at `post_apply`, observing, with a payload filter on
the Run kind it checks: `run.kind == chaos` makes it the assertions of every
chaos experiment in the Binding's scope.

Each assertion spans the window's start plus its own duration, cut at the
window's end:

- `event_emitted` — an Event of `eventType` lands within `within`, at or above
  `severity_gte` when given.
- `event_not_emitted` — no Event of `eventType` lands within `within`.
- `snapshot_field_gte` — an Observatory snapshot of `pillar` on the Run's Stack
  carries `field` at or above `value` within `within`.
- `snapshot_field_lte` — no such snapshot carries `field` above `value`
  throughout `throughout`.

An Event counts when it names the Run's Stack or names no Stack. The Verdict
passes when every assertion holds. It never changes the Run.
