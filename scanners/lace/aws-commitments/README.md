# lace/aws-commitments

Tracks AWS Reserved Instance + Savings Plan inventory, utilization, and coverage. Daily snapshots feed the Observatory commitments page and the recommendations engine's purchase-suggestion baseline.

## Outputs

- `snapshots/ri_snapshot` — one row per active RI, carrying purchased vs. utilized hours and unblended cost.
- `snapshots/sp_snapshot` — one row per active Savings Plan, carrying commitment $/hr, utilization %, and coverage %.

## Config

No required config. The scanner enumerates the org's active reservations + plans across every account in the payer connection.
