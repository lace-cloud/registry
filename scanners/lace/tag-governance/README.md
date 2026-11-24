# Tag Governance

Checks every resource Lace's inventory holds, on every cloud, against the
organization's tag policy, and raises a `tag-violation` finding for each
resource that breaks it. One Scanner serves every cloud: AWS tags and Google
Cloud labels are read alike, and each finding names the cloud its resource
lives on.

A resource breaks the policy when:

- it lacks a tag the policy marks required; or
- its `team` tag names a team code the organization has not registered.

Each scan writes a `tag-violation` finding per such resource, with the keys it
lacks, whether its team code is unregistered, and its tags. A missing required
tag is `medium`, and an unregistered team code `low`. Its URI is
`tag-violation://<provider>/<cloud id>`.

A finding belongs to the team its `team` tag's code is registered to. When the
tag is missing or its code is unregistered, it belongs to the team whose
connection reaches the resource's account.

It reads the resources other Scanners record, with their tags, so with no
inventory it raises nothing. It needs no billing anchor.

## Configuration

The tag policy is the organization's: the tag keys it marks required, and the
registered team codes. With no tag policy set, a scan raises nothing.
