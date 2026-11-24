# Cloud Inventory

Lists the resources of the account that holds the organization's billing as
the `resources` inventory, with a `resources.summary` snapshot of how many
there are in all, of each type and in each region. One Scanner serves every
cloud: each row names the cloud its resource lives on.

It needs a billing anchor, as `lace/cost` does: Lace refuses the install while
the organization has none on any cloud.

A scan reads each billing anchor's resources:

- On AWS, the billing account's resources that are tagged or were once
  tagged, from the Resource Groups Tagging API
  ([GetResources](https://docs.aws.amazon.com/resourcegroupstagging/latest/APIReference/API_GetResources.html)),
  through the account's anchor, under the Observatory policy its Terraform
  puts on the anchor's role at the basic tier, in each region Lace reads the
  account in. A resource that was never tagged is not listed.
- On Google Cloud, Lace reads no inventory, so a scan writes nothing there.

When the read of any region fails, the scan fails and writes nothing, so no
resource it listed before is dropped for want of a read.

Each row says what its resource is by the rule a drift scan's row says it by:
its cloud id (on AWS, its ARN, which is also the row's URI), the account it
lives in, its region and its tags. So a resource a drift scan of its Stack also
records reads as one resource, and `lace/tag-governance` checks its tags.
