# `internal` is consumer-chosen — public ALBs are this module's primary use
# case. Header hygiene is likewise exposed to the consumer.
#tfsec:ignore:AVD-AWS-0053
#tfsec:ignore:AVD-AWS-0052
resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.access_logs_bucket != null ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
