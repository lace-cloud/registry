# Rightsizing Recommendations

Reads recommendations to resize the resources of the account that holds the
organization's billing, and raises a `rightsize-recommendation` finding for
each resource a recommendation names. One Scanner serves every cloud: each
finding names the cloud its resource lives on.

It needs a billing anchor, as `lace/cost` does: Lace refuses the install while
the organization has none on any cloud.

A scan reads each billing anchor's recommendations:

- On AWS, Compute Optimizer's, through the billing account's anchor, under the
  Observatory policy its Terraform puts on the anchor's role at the advanced
  tier. It reads EC2 instances, EBS volumes, Lambda functions, Auto Scaling
  groups and ECS services. Compute Optimizer recommends only for an account
  opted in to it
  ([Getting started](https://docs.aws.amazon.com/compute-optimizer/latest/ug/getting-started.html)),
  so while the billing account's enrollment is not `Active`
  ([GetEnrollmentStatus](https://docs.aws.amazon.com/compute-optimizer/latest/APIReference/API_GetEnrollmentStatus.html)),
  a scan raises nothing. A kind of resource whose read fails is skipped; when
  every read is refused for want of permission, the scan fails and names the
  actions the anchor's role needs.
- On Google Cloud, Lace reads no recommendations, so a scan raises nothing
  there.

Each finding holds the resource's type, name and current size, the cloud's
assessment of it and the reasons for that assessment, its utilization over the
period the cloud looked back on, and the sizes it recommends, best first, each
with its estimated monthly savings in its currency, its performance risk and
its projected utilization. On AWS, a resource Compute Optimizer assesses
`Underprovisioned`, `Overprovisioned` or `NotOptimized` is `medium`, and any
other `info`.

Its URI is `rightsize-recommendation://<provider>/<ARN>`, so a second scan
that reads the same recommendation raises no second finding.
