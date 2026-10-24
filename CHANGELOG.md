# Changelog

## [1.0.3](https://github.com/Olensys/terraform-aws-sqs-queue/compare/v1.0.2...v1.0.3) (2026-10-24)


### Bug Fixes

* **examples:** unique application slug so concurrent integration runs do not collide ([#2](https://github.com/Olensys/terraform-aws-sqs-queue/issues/2)) ([a49bfd8](https://github.com/Olensys/terraform-aws-sqs-queue/commit/a49bfd86fb7975a8016b3252de8b9f867ba58b01))

## [1.0.2](https://github.com/Olensys/terraform-aws-sqs-queue/compare/v1.0.1...v1.0.2) (2026-10-24)


### Bug Fixes

* **examples:** pin naming module to v1.0.1 ([35b5e52](https://github.com/Olensys/terraform-aws-sqs-queue/commit/35b5e524251f0dea061afb6f7da9b2271c369da5))
* run integration on change and weekly instead of nightly ([019c372](https://github.com/Olensys/terraform-aws-sqs-queue/commit/019c37237e3b6c8cd32872784d261482bccf303a))

## 1.0.1

### Fixes

- render declared provider constraints and skip .terraform in trivy scans
- declare required_version and providers in examples/minimal
- gate redrive policy on DLQ, tighten name limit to 71, expose encryption output, strengthen tests

## 1.0.0

- SQS queue module wrapping terraform-aws-modules/sqs/aws 5.2.2: dead-letter queue by default, server-side encryption always on, optional FIFO with automatic .fifo suffix, optional consumer queue policy.
