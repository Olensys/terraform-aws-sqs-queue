locals {
  tags = merge(var.context.extra_tags, var.tags)

  # SSE is always on: a customer-managed key when supplied, SQS-managed otherwise.
  use_cmk = var.kms_key_arn != null

  encryption = {
    sqs_managed_sse_enabled = !local.use_cmk
    kms_master_key_id       = var.kms_key_arn
  }

  consumer_statements = length(var.consumer_principals) > 0 ? {
    consumers = {
      sid = "ConsumerAccess"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility",
      ]
      principals = [{ type = "AWS", identifiers = var.consumer_principals }]
    }
  } : {}
}

module "this" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "5.2.2"

  create = var.create

  # The upstream module appends ".fifo" itself when fifo_queue is true.
  name       = var.name
  fifo_queue = var.fifo

  visibility_timeout_seconds = var.visibility_timeout_s
  message_retention_seconds  = var.message_retention_s

  sqs_managed_sse_enabled = local.encryption.sqs_managed_sse_enabled
  kms_master_key_id       = local.encryption.kms_master_key_id

  create_dlq                    = var.dead_letter.enabled
  dlq_name                      = "${var.name}-dlq"
  dlq_message_retention_seconds = var.dead_letter.retention_s
  dlq_sqs_managed_sse_enabled   = local.encryption.sqs_managed_sse_enabled
  dlq_kms_master_key_id         = local.encryption.kms_master_key_id
  # Upstream merges deadLetterTargetArn only when create_dlq is true; with no DLQ a
  # non-empty redrive_policy would create a policy with no target, so pass {}.
  redrive_policy = var.dead_letter.enabled ? { maxReceiveCount = var.dead_letter.max_receive_count } : {}

  create_queue_policy     = length(var.consumer_principals) > 0
  queue_policy_statements = local.consumer_statements

  tags = local.tags
}
