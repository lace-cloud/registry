# lace/aws-drift

Detects drift between Lace-tracked stack state and live AWS resources. Runs periodically over every account+region in scope; for each tracked resource, compares the live state to the bundle's expected state and emits a `drift_state` snapshot.

## How it runs

- Runtime: `lace-managed` — handler ships in Lace's tree (`apps/api/src/lib/scanners/in-tree-handlers.ts`).
- Default cadence: every 60 minutes. Configurable via `intervalMinutes` (≥ 5).
- Scope: every AWS account that the org's payer connection covers, unless `accountIds` is set explicitly.

## Outputs

- `snapshots/drift_state` — one row per `(stackId, resourceUri)` pair, carrying `driftStatus ∈ {in_sync, drifted, unmanaged, missing}` and the observed-vs-expected attribute deltas.

The Observatory drift surface joins the latest snapshot per resource against bundle metadata to render the drift dashboard and to feed the chaos pillar's blast-radius calculations.

## Config

```yaml
accountIds: ["111111111111", "222222222222"]   # optional
regions: ["us-east-1", "us-west-2"]            # optional
intervalMinutes: 30                             # optional, default 60
```

## Versioning

Manifest version is updated when output sub-kind schemas change. Behavior changes inside the in-tree handler that don't break the wire schema do not require a version bump — they ship with the next Lace platform release.
