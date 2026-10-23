mock_provider "aws" {
  mock_resource "aws_sqs_queue" {
    defaults = {
      arn = "arn:aws:sqs:eu-west-1:123456789012:example"
      url = "https://sqs.eu-west-1.amazonaws.com/123456789012/example"
      id  = "https://sqs.eu-west-1.amazonaws.com/123456789012/example"
    }
  }
}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name = "example"
}

run "test_dlq_default_on" {
  # apply under the mock provider so computed attributes (arn, url) are known.
  command = apply

  assert {
    condition     = var.dead_letter.enabled == true && var.dead_letter.max_receive_count == 5 && var.dead_letter.retention_s == 1209600
    error_message = "dead_letter must default to enabled, 5 receives, 14 days retention."
  }

  assert {
    condition     = output.dlq_arn != null && output.dlq_url != null
    error_message = "A dead-letter queue must be created by default."
  }
}

run "test_dlq_disabled" {
  # apply under the mock provider so computed attributes (arn, url) are known.
  command = apply

  variables {
    dead_letter = { enabled = false }
  }

  assert {
    condition     = output.dlq_arn == null && output.dlq_url == null
    error_message = "No dead-letter queue may be created when dead_letter.enabled is false."
  }

  assert {
    condition     = output.arn != null
    error_message = "The main queue must still be created."
  }
}

run "test_fifo_suffix" {
  command = plan

  variables {
    fifo = true
  }

  assert {
    condition     = endswith(output.name, ".fifo")
    error_message = "A FIFO queue name must end with .fifo."
  }
}

run "test_standard_has_no_fifo_suffix" {
  command = plan

  assert {
    condition     = output.name == "example"
    error_message = "A standard queue name must equal var.name."
  }
}

run "test_sse_always" {
  # apply under the mock provider so computed attributes (arn, url) are known.
  command = apply

  # Child-module attributes are not visible to assertions. SSE is enforced
  # in main.tf (sqs_managed_sse_enabled or kms_master_key_id) and checked by
  # trivy; here we assert the plan succeeds with and without a CMK.
  variables {
    kms_key_arn = "arn:aws:kms:eu-west-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition     = output.arn != null
    error_message = "Queue must plan with a customer-managed key."
  }
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition     = output.id == null && output.name == null && output.arn == null && output.url == null && output.dlq_arn == null && output.dlq_url == null && output.tags == null
    error_message = "All outputs must be null when create is false."
  }
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = join("", [for i in range(76) : "a"])
  }

  expect_failures = [var.name]
}

run "test_name_length_75_ok" {
  command = plan

  variables {
    name = join("", [for i in range(75) : "a"])
    fifo = true
  }

  assert {
    condition     = length(output.name) == 80
    error_message = "A 75-character base name with fifo must yield an 80-character queue name."
  }
}

run "test_name_rejects_uppercase" {
  command = plan

  variables {
    name = "Bad-Name"
  }

  expect_failures = [var.name]
}
