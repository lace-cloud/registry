# lace/aws-recommendations

Surfaces cost-savings recommendations from AWS Compute Optimizer + Cost Explorer + Trusted Advisor as findings. Each finding carries a rationale + estimated monthly savings.

## Inputs

Calls AWS Compute Optimizer (`GetEC2InstanceRecommendations` + `GetRDSDatabaseRecommendations`), Cost Explorer (`GetSavingsPlansPurchaseRecommendation`, `GetReservationPurchaseRecommendation`), and Trusted Advisor (where the org has Business or Enterprise support). All via STS-minted per-account credentials.

## Outputs

- `findings/savings_recommendation` — carries the source, recommendation kind, current vs. recommended monthly cost, estimated savings. Powers the Observatory recommendations page.

## Config

```yaml
sources: [compute_optimizer, cost_explorer]
minMonthlySavingsUsd: 5.0
```

`trusted_advisor` is opt-in (requires Business or Enterprise support).
