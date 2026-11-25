# Commitments Utilization

Reads how much of its committed spend the account that holds the
organization's billing uses, and which commitments would cut its on-demand
spend. One Scanner serves every cloud: each snapshot and finding names the
cloud it was read on.

It needs the cloud account that holds the organization's billing, connected
with billing turned on, as `lace/cost` does: Lace refuses the install while
the organization has none on any cloud.

A scan reads the commitments of each such account:

- On AWS, from Cost Explorer, through the billing account's anchor, under the
  Observatory policy its Terraform puts on the anchor's role at the advanced
  tier. Cost Explorer answers a management account of an AWS organization for
  the whole organization. At the basic tier its reads are refused, so every
  scan fails.
- On Google Cloud, Lace reads no commitments, so a scan writes nothing there.

On AWS, each scan writes:

- a `commitments.utilization` snapshot of the last 30 days of Savings Plans,
  in US dollars: the share of the commitment used, the commitment used, unused
  and in total, the net savings against the on-demand cost of the same use,
  and the amortized commitment, for the whole window and for each period Cost
  Explorer reports. With no Savings Plan in the window, the snapshot holds
  none.
- a `commitment-recommendation` finding for a Compute Savings Plan, and one
  for Cost Explorer's EC2 Reserved Instance recommendation, which sums every
  instance purchase it lists, when Cost Explorer estimates the purchase would
  save money: each priced for a one-year term with no upfront payment, sized
  on the last 30 days of use, and carrying its estimated monthly savings in
  its currency, which its title names. A recommendation that saves 1,000 or
  more of its currency a month is `medium`, and any smaller `info`.

A failed read of the utilization fails the scan; a window Cost Explorer holds
no data for is not a failure. A failed read of a recommendation raises nothing
for it.

Each finding's URI names its cloud and the recommendation, the same at every
scan: `commitment-recommendation://<provider>/…`, so a scan that reads the
same recommendation again raises no second finding.
