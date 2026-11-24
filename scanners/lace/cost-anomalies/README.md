# Cost Anomalies

Finds spend that departed from its own trailing baseline, on every cloud, and
raises a `cost-anomaly` finding for each run of anomalous days. Lace computes
it itself, over the `cost.daily` rows `lace/cost` writes: one series of
`EffectiveCost` per cloud, account, service and currency. No cloud's own
anomaly service is read.

It needs a billing anchor, as `lace/cost` does, and reads only what
`lace/cost` has written, so without it it raises nothing.

## The rule

- A day is anomalous when its cost exceeds the mean of the 14 days before it
  by more than three of those days' standard deviations, and by at least 10
  units of its currency.
- A series with fewer than 14 days of history raises nothing.
- Consecutive anomalous days are one window, and one finding.

## The finding

Each `cost-anomaly` finding names its series' cloud, account and service, and
is in the series' currency:

- `expected` is the baseline mean times the window's days, `actual` the
  window's sum, `impact` their difference, and `deviationPct` their ratio;
- `attribution` names the service, region and account the cost came from;
- its severity is set by its impact.

Its URI is `cost-anomaly://<provider>/<account>/<service>/<window start>`, so a
second scan over the same window raises no second finding.
