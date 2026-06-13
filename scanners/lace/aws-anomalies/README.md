# lace/aws-anomalies

Detects statistical cost anomalies over the daily-amortized cost time-series produced by `lace/aws-cost`. Z-score-based; emits one `cost_anomaly` finding per detected anomaly, ranked by impact.

## Inputs

Reads the previous `lace/aws-cost` `cost_daily` time-series from the org's Observatory store. No external API calls.

## Outputs

- `findings/cost_anomaly` — carries the anomaly ID, observed vs. baseline daily cost, delta in USD, z-score, and severity. Surfaced on the Observatory anomalies page and the org dashboard hero card.

## Config

```yaml
sensitivity: medium                # low | medium | high
minDailyCostUsd: 1.0               # suppression floor
```

Sensitivity maps to z-score thresholds: low ≥ 4.0, medium ≥ 3.0, high ≥ 2.0.
