# Health

Reads the alarms of the account that holds the organization's billing, and
raises an `alarm-breach` finding for each alarm in breach, with a
`health.alarms` snapshot of every alarm it read. One Scanner serves every
cloud: each finding and snapshot names the cloud its alarms live on.

It needs a billing anchor, as `lace/cost` does: Lace refuses the install while
the organization has none on any cloud.

A scan reads each billing anchor's alarms:

- On AWS, the billing account's CloudWatch metric alarms, through its anchor,
  under the Observatory policy its Terraform puts on the anchor's role at the
  basic tier, in each region Lace reads the account in. An alarm in the
  `ALARM` state is in breach, one in `OK` is not, and one in
  `INSUFFICIENT_DATA` is unknown
  ([MetricAlarm](https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API_MetricAlarm.html)).
  A region whose read fails adds no alarms.
- On Google Cloud, Lace reads no alarms, so a scan writes nothing there.

Each scan writes:

- a `health.alarms` snapshot: how many alarms it read, how many are in
  breach, and each alarm's name, description, region, state and the reason
  for it, when the state last changed, the metric it watches, the condition
  it alarms on, whether its actions are enabled, and a link to it in the
  cloud's console;
- an `alarm-breach` finding, `high`, for each alarm in breach, holding the
  same facts. Its URI is the alarm's cloud id (on AWS, its ARN).
