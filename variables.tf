variable "name" {
  description = "Base queue name. Lowercase letters, digits and hyphens, at most 75 characters so that the \".fifo\" suffix and the \"-dlq\" companion name stay within the 80-character SQS limit."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,75}$", var.name))
    error_message = "name must match ^[a-z0-9-]{1,75}$."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "create" {
  description = "Whether to create any resources. Set false to create nothing."
  type        = bool
  default     = true
}

variable "fifo" {
  description = "Create a FIFO queue. The module appends the \".fifo\" suffix to the name."
  type        = bool
  default     = false
}

variable "visibility_timeout_s" {
  description = "Visibility timeout in seconds (0 to 43200)."
  type        = number
  default     = 30
  validation {
    condition     = var.visibility_timeout_s >= 0 && var.visibility_timeout_s <= 43200
    error_message = "visibility_timeout_s must be between 0 and 43200."
  }
}

variable "message_retention_s" {
  description = "How long messages are retained, in seconds (60 to 1209600). Default is 4 days."
  type        = number
  default     = 345600
  validation {
    condition     = var.message_retention_s >= 60 && var.message_retention_s <= 1209600
    error_message = "message_retention_s must be between 60 and 1209600."
  }
}

variable "dead_letter" {
  description = "Dead-letter queue settings. enabled creates the DLQ (named <name>-dlq); max_receive_count is receives before a message moves to the DLQ; retention_s is DLQ message retention in seconds."
  type = object({
    enabled           = optional(bool, true)
    max_receive_count = optional(number, 5)
    retention_s       = optional(number, 1209600)
  })
  default = {}
  validation {
    condition     = var.dead_letter.max_receive_count >= 1 && var.dead_letter.max_receive_count <= 1000
    error_message = "dead_letter.max_receive_count must be between 1 and 1000."
  }
  validation {
    condition     = var.dead_letter.retention_s >= 60 && var.dead_letter.retention_s <= 1209600
    error_message = "dead_letter.retention_s must be between 60 and 1209600."
  }
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN for encryption. Null uses SQS-managed server-side encryption. Encryption is always on."
  type        = string
  default     = null
}

variable "consumer_principals" {
  description = "IAM principal ARNs allowed to receive, delete, change visibility and read attributes of messages. Empty creates no queue policy."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags merged onto every taggable resource, applied last."
  type        = map(string)
  default     = {}
}
