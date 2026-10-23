# Changelog

## 1.0.1

### Fixes

- render declared provider constraints and skip .terraform in trivy scans
- declare required_version and providers in examples/minimal
- gate redrive policy on DLQ, tighten name limit to 71, expose encryption output, strengthen tests

## 1.0.0

- SQS queue module wrapping terraform-aws-modules/sqs/aws 5.2.2: dead-letter queue by default, server-side encryption always on, optional FIFO with automatic .fifo suffix, optional consumer queue policy.
