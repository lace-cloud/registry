# lace/aws-tag-governance

Audits AWS resources against the org's required-tag policy. For every resource missing a required tag (or carrying an invalid value when `allowedValues` is set), emits a `tag_violation` finding. Powers the Observatory governance page.

## Outputs

- `findings/tag_violation` — one row per (resource_uri, tag_key) violation, carrying observed value (when present) + allowed values (when constrained).

## Config

```yaml
requiredTags:
  - key: team
  - key: cost-center
  - key: env
    allowedValues: [prod, staging, dev]
severity: warning
```

The scanner joins against `lace/aws-cloud-inventory`'s tags column, so the inventory scanner must be installed first.
