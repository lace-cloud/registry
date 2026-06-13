# lace/aws-health

Pulls AWS Health events (issues, account notifications, scheduled changes) into Observatory's findings stream. The org's health surface renders these next to drift + cost signals so abnormal account state is visible alongside infrastructure state.

## Inputs

Reads via the AWS Health API (`DescribeEvents` + `DescribeAffectedEntities`). Requires Business or Enterprise support on the payer account.

## Outputs

- `findings/health_event` — one row per AWS Health event, carrying ARN, service, event type, status, severity, and affected entity ARNs. Surfaced on the Observatory health page.

## Config

```yaml
eventCategories: [issue, accountNotification, scheduledChange]
```

`investigation` events are opt-in (preview-tier only).
