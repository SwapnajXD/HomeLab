# Infrastructure-as-Code (IaC) Local AWS Simulation Manifests

This directory contains declarative Terraform configurations used to provision, validate, and experiment with AWS-style cloud architectures locally without incurring public cloud costs.

> **Note:** These Terraform manifests originated as a LocalStack implementation and are retained in this directory for historical reference. The same configurations are now actively used against the Floci AWS emulator running within the HomeLab environment.

---

## Architecture & Simulation Interface

The provisioning workflow targets the local cloud simulation backend hosted on **Athena**:

```text
[ Terraform Manifests ]
          │
          ▼
Terraform Execution
          │
          ▼
Target Endpoint: http://10.10.10.10:4566
          │
          ▼
Floci Native AWS Emulator
          │
 ┌────────┴────────┐
 ▼                 ▼
S3 Storage      DynamoDB
```

Floci provides AWS-compatible APIs on port `4566`, allowing standard Terraform workflows and AWS CLI commands to operate without modification.

### Legacy Compatibility

These manifests were originally developed against a pinned LocalStack deployment and remain compatible with that implementation. Preserving this directory demonstrates the evolution of the HomeLab environment while maintaining backward compatibility across local cloud platforms.

---

## Provisioned Resources

When applied, these configurations establish a lightweight data layer designed to mimic common cloud infrastructure patterns.

### `tf-homelab-storage-bucket`

**Type:** Amazon S3 Bucket

**Purpose:**

* Simulates object storage workflows
* Validates upload and retrieval operations
* Tests Terraform-managed storage provisioning
* Supports offline experimentation

---

### `tf-homelab-metadata`

**Type:** DynamoDB Table

**Purpose:**

* Simulates key-value and metadata workloads
* Validates table creation and persistence
* Exercises Terraform state management patterns
* Supports application lookup testing

---

## Standard Workflow

Execute these routines from **Artemis** or directly from **Athena**.

### 1. Initialize the Workspace

Prepare the Terraform working directory and validate configuration syntax.

```bash
terraform init
terraform validate
```

---

### 2. Review Planned Changes

Preview infrastructure modifications before applying them.

```bash
terraform plan
```

Expected outcome:

```text
Terraform will perform the following actions...
```

or, if already provisioned:

```text
No changes. Infrastructure matches the configuration.
```

---

### 3. Apply Infrastructure

Deploy the declared resources to the active Floci environment.

```bash
terraform apply -auto-approve
```

---

### 4. Verify Resource Creation

Confirm resources exist using the AWS CLI.

#### Verify S3 Buckets

```bash
aws --endpoint-url=http://10.10.10.10:4566 s3 ls
```

Expected output:

```text
tf-homelab-storage-bucket
```

#### Verify DynamoDB Tables

```bash
aws --endpoint-url=http://10.10.10.10:4566 dynamodb list-tables
```

Expected output:

```text
tf-homelab-metadata
```

---

### 5. Destroy Infrastructure

Remove all provisioned resources and reset the local cloud environment.

```bash
terraform destroy -auto-approve
```

---

## Directory Status

| Attribute                  | Value                                             |
| -------------------------- | ------------------------------------------------- |
| Directory Purpose          | Historical LocalStack Terraform Implementation    |
| Active Emulator            | Floci                                             |
| AWS Compatibility Endpoint | `http://10.10.10.10:4566`                         |
| Managed Resources          | S3, DynamoDB                                      |
| Terraform Workflow         | Active                                            |
| Portfolio Value            | Demonstrates migration and backward compatibility |

---

## Related Documentation

* `terraform/README.md`
* `docs/project-timeline.md`
* `docs/changelog.md`
* `docs/validation-report.md`
