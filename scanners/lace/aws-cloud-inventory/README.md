# lace/aws-cloud-inventory

Enumerates every AWS resource the org owns into the Observatory inventory store. Forms the join target for cost attribution (`lace/aws-cost`), drift detection (`lace/aws-drift`), tag governance (`lace/aws-tag-governance`), and chaos blast-radius calculations.

## Outputs

- `inventory/ec2_instance` — running + stopped EC2 instances.
- `inventory/rds_instance` — RDS database instances.
- `inventory/s3_bucket` — S3 buckets with encryption + public-access-block state.
- `inventory/lambda_function` — Lambda functions.

Additional sub-kinds ship with future versions of this scanner; consumers should treat `inventory.<sub_kind>` as an open vocabulary.

## Config

```yaml
resourceTypes: [ec2_instance, rds_instance, s3_bucket, lambda_function]   # opt-in subset
regions: [us-east-1, us-west-2]                                            # opt-in subset
```

Both fields default to the org's full coverage if omitted.
