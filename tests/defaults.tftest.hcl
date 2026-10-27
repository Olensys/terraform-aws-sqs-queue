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
  # SMOKE: the DLQ resource itself is in the child module; this observes only the outputs and variable defaults.
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
  command = plan

  assert {
    condition     = output.encryption.sqs_managed_sse_enabled == true && output.encryption.kms_master_key_id == null
    error_message = "Default must use SQS-managed SSE."
  }
}

run "test_sse_always_with_cmk" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:eu-west-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition     = output.encryption.sqs_managed_sse_enabled == false && output.encryption.kms_master_key_id == "arn:aws:kms:eu-west-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    error_message = "A supplied CMK must be passed as kms_master_key_id with SQS-managed SSE off."
  }
}

run "test_receive_wait_time_validation" {
  command = plan

  variables {
    receive_wait_time_s = 21
  }

  expect_failures = [var.receive_wait_time_s]
}

run "test_receive_wait_time_accepted" {
  # SMOKE: the value goes to the child module's queue and DLQ; this proves the input plans.
  command = plan

  variables {
    receive_wait_time_s = 20
  }

  assert {
    condition     = var.receive_wait_time_s == 20
    error_message = "receive_wait_time_s must accept 20."
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
    name = join("", [for i in range(72) : "a"])
  }

  expect_failures = [var.name]
}

run "test_name_length_71_ok" {
  command = plan

  variables {
    name = join("", [for i in range(71) : "a"])
    fifo = true
  }

  assert {
    condition     = length(output.name) == 76
    error_message = "A 71-character base name with fifo must yield a 76-character queue name."
  }
}

run "test_name_rejects_uppercase" {
  command = plan

  variables {
    name = "Bad-Name"
  }

  expect_failures = [var.name]
}

run "test_tags_contract" {
  command = plan

  variables {
    tags = { Owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { Owner = "y", Team = "z" }
    }
  }

  assert {
    condition     = output.tags.Owner == "x" && output.tags.Team == "z"
    error_message = "var.tags must win over context.extra_tags, and extra_tags must be merged."
  }
}
