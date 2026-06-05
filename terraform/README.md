# Terraform

## Purpose

This directory contains Infrastructure as Code (IaC) configurations used to provision and manage HomeLab resources.

Terraform is primarily used with LocalStack to simulate AWS services for learning, testing, and development workflows.

---

## Contents

### `localstack/`

Local AWS-compatible infrastructure environment.

Resources currently include:

* S3 Buckets
* DynamoDB Tables

Additional environments may be added as the HomeLab expands.

---

## Usage

Initialize Terraform:

```bash
terraform init
```

Validate configuration:

```bash
terraform validate
```

Review planned changes:

```bash
terraform plan
```

Apply infrastructure:

```bash
terraform apply
```

---

## Dependencies

* Terraform CLI
* LocalStack
* AWS CLI (optional for validation)

---

## Maintenance

* Keep state files out of version control unless intentionally managed.
* Review provider versions periodically.
* Document all infrastructure changes in `docs/changelog.md`.
* Test changes in LocalStack before expanding to additional environments.

---

## Status

**Infrastructure as Code:** Operational

**Primary Environment:** LocalStack

**Documentation Status:** Current
