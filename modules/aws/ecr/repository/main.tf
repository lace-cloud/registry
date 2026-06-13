# Tag mutability is consumer-chosen via var.image_tag_mutability; the module
# must support mutable repos (the AWS default) as well as immutable ones.
#tfsec:ignore:AVD-AWS-0031
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  dynamic "encryption_configuration" {
    for_each = var.encryption_type != null ? [1] : []
    content {
      encryption_type = var.encryption_type
      kms_key         = var.kms_key
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  count      = length(var.lifecycle_rules) > 0 ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      for i, rule in var.lifecycle_rules : {
        rulePriority = i + 1
        description  = lookup(rule, "description", "Lifecycle rule ${i + 1}")
        selection = {
          tagStatus     = rule.tag_status
          tagPrefixList = lookup(rule, "tag_prefix_list", null)
          countType     = rule.count_type
          countNumber   = rule.count_number
          countUnit     = lookup(rule, "count_unit", null)
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
