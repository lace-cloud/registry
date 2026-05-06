# lace/aws

Lace's first-party chaos provider for AWS. Mutates tags on EC2 instances and rolls back by reapplying the pre-mutation tag value (the `inverse_action` strategy).

## Supported targets

| Resource type | URI pattern                                                     | Actions       | Rollback kinds   |
|---------------|-----------------------------------------------------------------|---------------|------------------|
| `aws_instance` | `arn:aws:ec2:{region}:{accountId}:instance/{instanceId}`       | `mutate_tag`  | `inverse_action` |

v1.0.0 ships the `mutate_tag` action only. Future versions add `terminate_instance`, `revoke_sg_rule`, and `inflate_cost`. Each new action is a manifest version bump.

## How it runs

- Runtime: `lace-managed` — handler ships in `apps/cli/internal/chaos/aws/`. Registered via `apps/cli/internal/chaos/registry/builtins/aws.go`'s `init()` side-effect.
- Credentials: per-run STS-minted by the cred broker; the manifest does not declare an OIDC trust because dispatch is in-tree.
- Callback signing: `none`. In-tree dispatch reports receipts back through the runner's internal RPC; no customer-hosted webhook is involved.

## Config

```yaml
region: us-east-1   # optional override; defaults to the install's region
```

## Versioning

Bump the manifest version when:

- A new `actions[]` entry is added.
- A new `rollbackKinds[]` entry is added.
- A new `targets[]` entry is added (e.g. when v1.1 adds RDS).
- The `aws_instance` URI pattern changes.

Internal handler-code changes that don't shift the published vocabulary do not require a manifest version bump — they ship with the next Lace platform release.
