# lace/aws-cost

Pulls AWS Cost & Usage Report (CUR) data into Observatory's finops surface. Reads daily-partitioned Parquet exports from the customer's CUR S3 bucket, normalizes against the payer-account billing root, and emits one `cost_daily` time-series row per (cloud_account_id, service, region, resource_uri, team_id, stack_id) tuple per day.

## How it runs

- Runtime: `lace-managed` — handler ships in `apps/api/src/lib/observatory/providers/aws/`.
- Cadence: daily, after the CUR export window closes.
- Scope: every account under the configured payer connection, joined against `finops_resource` for team + stack attribution.

## Outputs

- `time_series/cost_daily` — granularity `daily`, metrics `[unblended_cost_usd, amortized_cost_usd, usage_amount]`. Powers the Observatory cost surface (org-level + team-level + stack-level + resource-level drill-down).

## Config

```yaml
payerAccountId: "111111111111"
curBucket: "my-cur-export"
curPrefix: "cur/v2-parquet"
region: "us-east-1"
```

The handler reads the bucket via the install's per-org STS-mint flow (no long-lived credentials).
