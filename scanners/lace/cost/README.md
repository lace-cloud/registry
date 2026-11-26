# Cost Scanner

Reads the organization's daily cost on every cloud it holds billing on, and
records it as one series. One Scanner serves every cloud: each row names the
cloud it was billed on.

It needs the cloud account that holds the organization's billing: an AWS
account or Google Cloud project an org admin connected with billing turned on.
Lace refuses the install while the organization has none on any cloud, and a
scan is skipped while it has none.

A scan reads the billing data of each such account:

- On AWS, Cost Explorer, through the billing account's anchor, under the
  Observatory policy its Terraform puts on the anchor's role.
- On Google Cloud, the billing export table in BigQuery that the anchor's
  billing block names, as the anchor's billing identity, which holds BigQuery
  Data Viewer on the export's dataset and BigQuery Job User on the project. A
  row of the export that names no currency takes the anchor's billing
  currency.

Each scan writes:

- `cost.daily`: each day's `EffectiveCost` and `BilledCost`, by `service` and
  `account`;
- `cost.attribution_by_team`, each day's `EffectiveCost` by the `team` tag (a
  cost allocation tag on AWS, a label on Google Cloud), with untagged cost
  under `(untagged)`;
- `cost.forecast`, the coming months' forecast, where the cloud gives one
  (AWS);
- a `cost.monthly_trend` snapshot of the monthly totals;
- the names of the AWS accounts it reports, so cost views show a name rather
  than an account ID.

Every amount is in the currency its row names, and no total adds two
currencies.

On AWS, a resource's `team` tag reaches its cost only once `team` is activated
as a cost allocation tag in AWS Billing.
