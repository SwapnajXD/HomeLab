# Infrastructure Changelog

## Purpose

This document records significant infrastructure changes, deployments, migrations, validations, refactoring efforts, and operational milestones within the HomeLab environment.

It serves as a historical record of the environment's evolution, architectural decisions, technical debt reduction, and reliability improvements.

---

# Phase 8: Documentation & Standardization (Current)

## Added

* `docs/architecture.md` — Infrastructure topology and service relationships
* `docs/network.md` — Network design, routing, and connectivity documentation
* `docs/inventory.md` — Infrastructure asset inventory
* `docs/runbook.md` — Operational procedures and maintenance tasks
* `docs/troubleshooting.md` — Incident history and resolutions
* `docs/disaster-recovery.md` — Recovery procedures and priorities
* `docs/validation-report.md` — Infrastructure validation records
* `docs/project-timeline.md` — Project evolution and milestones
* `docs/changelog.md` — Historical change tracking

## Changed

* Repository structure standardized across all documentation.
* Consistent Markdown formatting and naming conventions adopted.
* README files added throughout the repository.

## Benefits

* Improved maintainability.
* Reduced operational knowledge loss.
* Faster onboarding and troubleshooting.
* Portfolio-ready documentation comparable to enterprise environments.

---

# Phase 7: Infrastructure Consolidation & Platform Refactoring (June 2026)

## Added

### Grafana Alloy

Deployed Grafana Alloy as the centralized telemetry agent for log collection.

### Floci Migration

Migrated from LocalStack to Floci Native AWS Emulator.

Benefits:

* Faster startup (~0.015 seconds)
* Lower memory usage (~13 MiB)
* Persistent mode support
* Native AWS API compatibility

### Inter-Node Synchronization

Implemented passwordless Ed25519 SSH authentication between Athena and Hestia to support automated data synchronization.

Features:

* Secure file transfers
* Automated cron-based synchronization
* Dashboard data replication

### Loki Hardening

Configured single-node Loki deployment using:

```yaml
replication_factor: 1

kvstore:
  store: inmemory
```

## Changed

Previous structure:

```text
~/homelab/
├── monitoring/
└── core-services/
```

New structure:

```text
~/homelab/docker-compose/
├── telemetry/
├── core-services/
└── floci/
```

### Telemetry Consolidation

Unified:

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Exporters

into a single deployment stack.

### Deployment Standardization

* Docker deployment workflows standardized.
* `.gitignore` hardened for persistent volumes and state files.

## Removed

* Promtail
* Legacy monitoring directories
* Obsolete network artifacts
* Unused Proxmox bridge (`vmbr1`)
* Active LocalStack deployment (retained only for historical reference)

## Fixed

* Apollo outbound NAT failures after Proxmox reboot.
* Missing masquerade rules causing guest connectivity loss.
* Docker container naming conflicts.
* Loki readiness endpoint instability.
* Root-owned directory permission inconsistencies.

## Validated

* Metrics pipeline functionality.
* Logging pipeline functionality.
* Grafana Explore integration.
* Telemetry deployment workflows.
* Inter-node synchronization.
* Floci operation and Terraform compatibility.

---

# Phase 6: Reliability Engineering & Recovery Testing

## Added

* Structured recovery validation procedures.
* Recovery testing methodology.
* Headless operations verification.
* Disaster recovery playbooks.

## Validated

### Headless Operations

Verified complete infrastructure administration without:

* Monitor
* Keyboard
* Mouse

Managed successfully using:

* Tailscale
* SSH
* Grafana
* Portainer
* Homepage

### Autostart Validation

Verified automatic startup of:

* Athena (VM 100)
* Hestia (LXC 101)

following Apollo reboot.

### Chaos Recovery Testing

Validated:

* Hypervisor reboot recovery
* VM recovery
* Container recovery
* Service recovery
* Docker restart policies
* Tailscale reconnection

## Result

All recovery scenarios completed successfully.

---

# Phase 5: Infrastructure as Code (IaC)

## Added

### Local AWS Emulation

Initially deployed LocalStack providing:

* S3
* DynamoDB

Later migrated to Floci.

### Terraform

Implemented Infrastructure as Code workflows.

## Provisioned Resources

### S3 Bucket

```text
tf-homelab-storage-bucket
```

### DynamoDB Table

```text
tf-homelab-metadata
```

## Validated

* Resource creation
* Resource persistence
* State management
* Terraform lifecycle operations
* Destroy and rebuild workflows

---

# Phase 4: Monitoring, Logging & Alerting

## Added

### Metrics Platform

* Prometheus
* Node Exporter
* Proxmox Exporter

### Visualization Platform

* Grafana
* Infrastructure dashboards

### Logging Platform

* Loki
* Promtail (later replaced by Alloy)

### Alerting Platform

* Grafana Alerting
* Telegram notifications

## Architecture

### Metrics Pipeline

```text
Node Exporter
        │
        ▼
Prometheus
        │
        ▼
Grafana
        │
        ▼
Telegram
```

### Logging Pipeline

```text
Docker Containers
        │
        ▼
Grafana Alloy
        │
        ▼
Loki
        │
        ▼
Grafana Explore
```

## Validated

* Metrics collection
* Dashboard rendering
* Log aggregation
* Alert delivery
* Historical visibility

---

# Phase 3: Core Services

## Added

### Homepage

Features:

* Centralized dashboard
* Service categorization
* Widget integrations

### Vaultwarden

Features:

* Self-hosted password management
* Persistent storage
* Secure credential management

### Portainer

Features:

* Container administration
* Deployment visibility
* Runtime inspection

## Validated

* Homepage functionality
* Widget integrations
* Vaultwarden authentication
* Data persistence
* Portainer accessibility

---

# Phase 2: Remote Access & Security

## Added

### Tailscale Deployment

Connected:

* Artemis (Management Workstation)
* Apollo (Proxmox Host)
* Athena (Operations VM)

## Benefits

* Secure remote administration
* SSH access
* MagicDNS resolution
* Headless management
* Elimination of router port forwarding

## Validated

* Remote connectivity
* DNS resolution
* Cross-node communication
* Overlay network stability

---

# Phase 1: Infrastructure Foundation

## Added

### Physical Infrastructure

* Apollo Proxmox VE Hypervisor

### Virtual Infrastructure

* Athena Ubuntu Server VM
* Hestia Alpine Linux Container

### Platform Services

* Docker
* Docker Compose

### Networking

* Proxmox bridge networking (`vmbr0`)
* Internal virtual networking

## Fixed

* Initial DHCP allocation issues.
* Bridge configuration anomalies.
* Firewall routing conflicts.

## Result

A stable virtualization platform capable of hosting isolated workloads and future infrastructure growth was established.

---

# Operational Milestones

| Milestone                     | Status   |
| ----------------------------- | -------- |
| Proxmox Deployment            | Complete |
| Remote Administration         | Complete |
| Core Services Deployment      | Complete |
| Monitoring Platform           | Complete |
| Centralized Logging           | Complete |
| Alerting Platform             | Complete |
| Infrastructure as Code        | Complete |
| Floci Migration               | Complete |
| Inter-Node Synchronization    | Complete |
| Recovery Testing              | Complete |
| Documentation Standardization | Complete |

---

# Current Environment Status

```text
Stable Operational Environment
```

## Active Capabilities

* Virtualization
* Containerization
* Monitoring
* Logging
* Alerting
* Infrastructure as Code
* Disaster Recovery
* Remote Administration
* Documentation
* Local AWS Emulation
* Inter-Node Data Synchronization

---

# Future Roadmap

## Planned Improvements

* Automated backup verification
* Enhanced observability dashboards
* Additional service integrations
* CI/CD experimentation
* Infrastructure automation expansion
* Long-term metrics retention strategy
* Service health automation
* ESP32 telemetry integration

---

# Document Status

**Changelog Status:** Current
**Infrastructure State:** Operational
**Operational Readiness:** Validated
**Documentation Coverage:** Complete
