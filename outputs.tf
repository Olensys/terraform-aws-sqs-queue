output "id" {
  description = "Identifier (URL) of the main queue. Null when create is false."
  value       = var.create ? module.this.queue_id : null
}

output "name" {
  description = "Name of the main queue, including the .fifo suffix for FIFO queues. Null when create is false."
  value       = var.create ? module.this.queue_name : null
}

output "arn" {
  description = "ARN of the main queue. Null when create is false."
  value       = var.create ? module.this.queue_arn : null
}

output "url" {
  description = "URL of the main queue. Null when create is false."
  value       = var.create ? module.this.queue_url : null
}

output "dlq_arn" {
  description = "ARN of the dead-letter queue. Null when create is false or the dead-letter queue is disabled."
  value       = var.create && var.dead_letter.enabled ? module.this.dead_letter_queue_arn : null
}

output "dlq_url" {
  description = "URL of the dead-letter queue. Null when create is false or the dead-letter queue is disabled."
  value       = var.create && var.dead_letter.enabled ? module.this.dead_letter_queue_url : null
}

output "tags" {
  description = "Tags applied to every taggable resource, with context.extra_tags merged in. Null when create is false."
  value       = var.create ? local.tags : null
}
