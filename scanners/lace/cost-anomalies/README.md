# Cost Anomalies

Finds spend that departed from its own trailing baseline, on every cloud, and
raises a `cost-anomaly` finding for each run of anomalous days. Lace computes
it itself, over the `cost.daily` rows `lace/cost` writes: one series of
`EffectiveCost` per cloud, account, service and currency. No cloud's own
anomaly service is read.

It needs the cloud account that holds the organization's billing, connected
with billing turned on, as `lace/cost` does, and reads only what
`lace/cost` has written, so without it it raises nothing.

## The rule

- A day is anomalous when its cost exceeds the mean of the 10 days before it
  by more than three of those days' standard deviations.
- A series with fewer than 10 days of history raises nothing.
- Consecutive anomalous days are one window. A window raises a finding only
  when its impact is at least 40% of its expected spend and at least 100 US
  dollars.
- Only a series billed in US dollars is judged.

## The finding

Each `cost-anomaly` finding names its series' cloud, account and service, and
is in US dollars:

- `expected` is the baseline mean times the window's days, `actual` the
  window's sum, `impact` their difference, and `deviationPct` their ratio;
- `attribution` names the service, region and account the cost came from;
- its severity is set by its impact: critical from 1,000 US dollars, high
  from 250, medium below.

Its URI is `cost-anomaly://<provider>/<account>/<service>/<window start>`, so a
second scan over the same window raises no second finding.
