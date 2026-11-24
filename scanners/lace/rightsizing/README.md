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
  tier, in each region the organization's connections in the account record.
  It reads EC2 instances, EBS volumes, Lambda functions, Auto Scaling groups
  and ECS services. Compute Optimizer recommends only for an account
  opted in to it
  ([Getting started](https://docs.aws.amazon.com/compute-optimizer/latest/ug/getting-started.html)),
  so while the billing account's enrollment is not `Active`
  ([GetEnrollmentStatus](https://docs.aws.amazon.com/compute-optimizer/latest/APIReference/API_GetEnrollmentStatus.html)),
  a scan raises nothing. A kind of resource whose read fails is skipped; when
  every read fails and one of them is refused for want of permission, the
  scan fails and names the actions the anchor's role needs. At the basic tier
  every read is refused, so every scan fails that way.
- On Google Cloud, Lace reads no recommendations, so a scan raises nothing
  there.

Each finding holds the resource's type, its account and current size, its name
where the cloud gives one (on AWS, an EC2 instance's or an Auto Scaling
group's), the cloud's assessment of it and the reasons for that assessment
where the cloud gives them (Compute Optimizer gives none for EBS volumes and
Auto Scaling groups), whether it is idle (on AWS, for an EC2 instance), its
utilization over the period the cloud looked back on and that period's length,
when the recommendation was last refreshed, and the sizes it recommends, each
with its estimated monthly savings in its currency (on AWS, Compute
Optimizer's estimate before discounts), its performance risk where the cloud
gives one (Compute Optimizer gives none for Lambda functions and ECS services)
and its projected utilization where the cloud gives it. The sizes are best
first where the cloud ranks them; Compute Optimizer ranks none for ECS
services, which keep its order. A resource the cloud judges rightly sized is
raised too. On AWS, a resource Compute Optimizer assesses `Underprovisioned`,
`Overprovisioned` or `NotOptimized` is `medium`, and any other `info`.

Its URI is `rightsize-recommendation://<provider>/<ARN>`, so a second scan
that reads the same recommendation raises no second finding.
