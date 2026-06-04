# Changelog

All significant infrastructure changes, deployments, migrations, and validation activities are recorded here.

---

# Initial Build Phase

## Proxmox Deployment

### Added

- Installed Proxmox VE on Apollo
- Configured storage
- Configured networking
- Created initial VM and LXC workloads

---

## Internal Networking

### Added

- Internal bridge networking
- VM communication
- LXC communication

### Resolved

- DHCP allocation issues
- Bridge configuration issues
- Firewall routing conflicts

---

# Remote Access Phase

## Tailscale Deployment

### Added

- Tailscale connectivity
- Secure remote administration
- Remote SSH access

### Validated

- Remote management from Artemis
- Headless operation support

---

# Core Services Phase

## Homepage Deployment

### Added

- Homepage Dashboard
- Service Categorization
- Monitoring Widgets

### Validated

- Dashboard accessibility
- Service discovery
- Widget integrations

---

## Vaultwarden Deployment

### Added

- Password management service
- Persistent storage

### Validated

- Authentication
- Data persistence

---

# Monitoring Phase

## Prometheus Deployment

### Added

- Metrics collection
- Target scraping

### Validated

- Node Exporter integration
- Proxmox Exporter integration

---

## Grafana Deployment

### Added

- Metrics visualization
- Dashboard creation

### Validated

- Prometheus datasource
- Dashboard rendering

---

## Loki Deployment

### Added

- Centralized log aggregation

### Validated

- Log ingestion
- Grafana Explore integration

---

## Promtail Deployment

### Added

- Log shipping pipeline

### Validated

- Container log collection
- Loki integration

---

# Infrastructure Consolidation

## Telemetry Refactor

### Changed

Previous Structure:

```text
monitoring/
core-services/
```

New Structure:

```text
docker-compose/
├── telemetry/
├── core-services/
└── localstack/
```

### Benefits

- Cleaner organization
- Easier maintenance
- Consistent deployment workflows

---

# Infrastructure as Code

## LocalStack Deployment

### Added

- AWS-compatible local cloud environment

### Services

- S3
- DynamoDB

### Validated

- Endpoint accessibility
- Service functionality

---

## Terraform Deployment

### Added

Infrastructure provisioning through code.

### Created

S3 Bucket:

```text
tf-homelab-storage-bucket
```

DynamoDB Table:

```text
tf-homelab-metadata
```

### Validated

```bash
terraform apply
```

Successful resource creation.

---

# Reliability Testing

## Headless Operation Validation

### Completed

- Removed monitor
- Removed keyboard
- Removed mouse

### Verified

Complete remote administration.

---

## Autostart Validation

### Completed

Enabled:

```text
Start at Boot
```

For:

- Hestia
- Athena

### Verified

Successful startup after reboot.

---

## Recovery Validation

### Completed

Tested:

- Hypervisor reboot
- Container restart
- Infrastructure destruction
- Infrastructure recreation

### Result

All systems recovered successfully.

---

# Documentation Phase

## Added

- architecture.md
- network.md
- runbook.md
- troubleshooting.md
- validation-report.md
- disaster-recovery.md
- inventory.md
- changelog.md

### Goal

Maintain complete operational documentation and infrastructure knowledge.

---

# Current Status

Infrastructure State:

```text
Operational
```

Capabilities:

- Virtualization
- Monitoring
- Logging
- Infrastructure as Code
- Disaster Recovery
- Remote Administration
- Documentation

---

# Future Roadmap

Planned Areas:

- Backup Automation
- ESP32 Telemetry Integration
- Additional Monitoring
- Service Expansion
- CI/CD Workflows