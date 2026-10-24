# terraform-aws-sqs-queue

SQS queue with a dead-letter queue by default, server-side encryption always on, optional FIFO

## Opinions

- A dead-letter queue is created by default (`<name>-dlq`, 5 receives, 14 days retention); disable with `dead_letter = { enabled = false }`.
- Server-side encryption is always on: SQS-managed by default, or the customer-managed key in `kms_key_arn`. It cannot be switched off. The same setting applies to the dead-letter queue.
- The `.fifo` suffix is appended automatically when `fifo = true`; pass the base name only. `name` is limited to 71 characters (80 minus 5 for `.fifo` and 4 for the `-dlq` companion) so that the FIFO suffix and the dead-letter queue name both stay within the 80-character SQS limit. The limit is fixed rather than dependent on `fifo` or `dead_letter` because variable validations on Terraform 1.5 cannot read other variables.
- `consumer_principals` creates a queue policy allowing `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes` and `sqs:ChangeMessageVisibility` to those principals. Empty means no queue policy.

## Usage

```hcl
module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"
  context = var.context
}

module "sqs_queue" {
  source  = "git::https://github.com/Olensys/terraform-aws-sqs-queue.git?ref=v1.0.1"
  name    = module.naming.name
  context = var.context

  tags = module.naming.tags
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_this"></a> [this](#module\_this) | terraform-aws-modules/sqs/aws | 5.2.2 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base queue name. Lowercase letters, digits and hyphens, at most 71 characters (80 minus 5 for ".fifo" and 4 for "-dlq") so the FIFO suffix and the dead-letter queue name both fit the 80-character SQS limit. | `string` | n/a | yes |
| <a name="input_consumer_principals"></a> [consumer\_principals](#input\_consumer\_principals) | IAM principal ARNs allowed to receive, delete, change visibility and read attributes of messages. Empty creates no queue policy. | `list(string)` | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to create nothing. | `bool` | `true` | no |
| <a name="input_dead_letter"></a> [dead\_letter](#input\_dead\_letter) | Dead-letter queue settings. enabled creates the DLQ (named <name>-dlq); max\_receive\_count is receives before a message moves to the DLQ; retention\_s is DLQ message retention in seconds. | <pre>object({<br/>    enabled           = optional(bool, true)<br/>    max_receive_count = optional(number, 5)<br/>    retention_s       = optional(number, 1209600)<br/>  })</pre> | `{}` | no |
| <a name="input_fifo"></a> [fifo](#input\_fifo) | Create a FIFO queue. The module appends the ".fifo" suffix to the name. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Customer-managed KMS key ARN for encryption. Null uses SQS-managed server-side encryption. Encryption is always on. | `string` | `null` | no |
| <a name="input_message_retention_s"></a> [message\_retention\_s](#input\_message\_retention\_s) | How long messages are retained, in seconds (60 to 1209600). Default is 4 days. | `number` | `345600` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags merged onto every taggable resource, applied last. | `map(string)` | `{}` | no |
| <a name="input_visibility_timeout_s"></a> [visibility\_timeout\_s](#input\_visibility\_timeout\_s) | Visibility timeout in seconds (0 to 43200). | `number` | `30` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the main queue. Null when create is false. |
| <a name="output_dlq_arn"></a> [dlq\_arn](#output\_dlq\_arn) | ARN of the dead-letter queue. Null when create is false or the dead-letter queue is disabled. |
| <a name="output_dlq_url"></a> [dlq\_url](#output\_dlq\_url) | URL of the dead-letter queue. Null when create is false or the dead-letter queue is disabled. |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | Encryption settings passed to the queue and its dead-letter queue: sqs\_managed\_sse\_enabled and kms\_master\_key\_id. Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Identifier (URL) of the main queue. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Name of the main queue, including the .fifo suffix for FIFO queues. Null when create is false. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to every taggable resource, with context.extra\_tags merged in. Null when create is false. |
| <a name="output_url"></a> [url](#output\_url) | URL of the main queue. Null when create is false. |
<!-- END_TF_DOCS -->
