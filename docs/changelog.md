# Infrastructure Changelog

## Purpose

This document records significant infrastructure changes, deployments, migrations, improvements, validations, and operational milestones within the HomeLab environment.

The changelog serves as a historical record of infrastructure evolution, architectural decisions, technical debt resolution, operational improvements, and future planning.

---

## Phase 8: Documentation & Standardization (Current)

### Added

* `docs/architecture.md` — Infrastructure topology and service relationships
* `docs/network.md` — Network design and connectivity documentation
* `docs/inventory.md` — Infrastructure asset inventory
* `docs/runbook.md` — Operational procedures and maintenance tasks
* `docs/troubleshooting.md` — Incident history and resolutions
* `docs/disaster-recovery.md` — Recovery procedures and priorities
* `docs/validation-report.md` — Infrastructure validation records
* `docs/changelog.md` — Historical change tracking

### Changed

* Repository restructured to comply with documentation standards
* Documentation hierarchy standardized across the repository
* Added README documentation throughout project directories

### Benefits

* Improved maintainability
* Reduced operational knowledge loss
* Faster troubleshooting and onboarding
* Consistent documentation standards

---

## Phase 7: Infrastructure Consolidation & Telemetry Refactoring (June 2026)

### Added

* Grafana Alloy deployed as the centralized telemetry agent
* Single-node Loki configuration:

  * `replication_factor: 1`
  * `kvstore: inmemory`
* Unified telemetry stack deployment model

### Changed

Previous structure:

```text
~/homelab/
├── monitoring/
├── core-services/
```

New structure:

```text
~/homelab/docker-compose/
├── telemetry/
├── core-services/
└── localstack/
```

* Consolidated Prometheus, Loki, Exporters, and Alloy into a single telemetry stack
* Hardened `.gitignore` rules for persistent volumes and state files
* Standardized Docker deployment workflows

### Removed

* Promtail
* Stale Proxmox bridge (`vmbr1`)
* Legacy monitoring directories
* Obsolete network configuration artifacts

### Fixed

* Root-owned directory permission issues
* Docker container naming conflicts
* Loki readiness endpoint instability
* Legacy deployment inconsistencies

### Validated

* End-to-end metrics pipeline
* End-to-end logging pipeline
* Grafana Explore integration
* Telemetry stack deployment workflow

---

## Phase 6: Reliability Testing

### Added

* Structured recovery validation procedures
* Recovery testing methodology
* Headless operation verification

### Validated

#### Headless Operations

Verified complete infrastructure management without:

* Monitor
* Keyboard
* Mouse

Confirmed functionality through:

* Tailscale
* SSH
* Grafana
* Portainer
* Homepage

#### Autostart Validation

Verified automatic startup of:

* Athena (VM)
* Hestia (LXC)

after Apollo reboot.

#### Chaos Recovery Testing

Validated:

* Hypervisor reboot recovery
* VM recovery
* Container recovery
* Service recovery
* Tailscale reconnection

### Result

All recovery tests completed successfully.

---

## Phase 5: Infrastructure as Code (IaC)

### Added

#### LocalStack

Deployed local AWS-compatible environment providing:

* S3
* DynamoDB

#### Terraform

Implemented Infrastructure as Code workflows.

### Provisioned Resources

#### S3 Bucket

```text
tf-homelab-storage-bucket
```

#### DynamoDB Table

```text
tf-homelab-metadata
```

### Validated

* Resource creation
* Resource persistence
* State management
* Terraform deployment lifecycle

---

## Phase 4: Monitoring, Logging & Alerting

### Added

#### Metrics Platform

* Prometheus
* Node Exporter
* Proxmox Exporter

#### Visualization Platform

* Grafana
* Infrastructure Dashboards

#### Logging Platform

* Loki
* Promtail (later replaced by Alloy)

#### Alerting Platform

* Grafana Alerting
* Telegram Contact Points

### Architecture

```text
Metrics

Node Exporter
        │
        ▼
Prometheus
        │
        ▼
Grafana

Logs

Docker Containers
        │
        ▼
Grafana Alloy
        │
        ▼
Loki
        │
        ▼
Grafana
```

### Validated

* Metrics collection
* Dashboard rendering
* Log aggregation
* Alert delivery
* Historical data visibility

---

## Phase 3: Core Services

### Added

#### Homepage

Features:

* Service dashboard
* Infrastructure visibility
* Widget integrations

#### Vaultwarden

Features:

* Password management
* Persistent storage
* Self-hosted credential management

### Validated

* Homepage dashboard functionality
* Widget integrations
* Vaultwarden authentication
* Data persistence

---

## Phase 2: Remote Access

### Added

#### Tailscale Deployment

Connected:

* Artemis (Management Workstation)
* Apollo (Proxmox Host)
* Athena (Monitoring VM)

### Benefits

* Secure remote administration
* SSH access
* MagicDNS support
* Elimination of port forwarding

### Validated

* Remote connectivity
* DNS resolution
* Cross-node communication
* Headless administration

---

## Phase 1: Infrastructure Foundation

### Added

#### Physical Infrastructure

* Apollo Proxmox VE Hypervisor

#### Virtual Infrastructure

* Athena Ubuntu Server VM
* Hestia Linux Container

#### Platform Services

* Docker
* Docker Compose

#### Networking

* Proxmox bridge networking (`vmbr0`)
* Internal virtual networking

### Fixed

* DHCP allocation issues
* Initial bridge configuration anomalies
* Firewall routing conflicts

### Result

Stable virtualization platform established.

---

## Operational Milestones

| Milestone                     | Status   |
| ----------------------------- | -------- |
| Proxmox Deployment            | Complete |
| Remote Administration         | Complete |
| Core Services Deployment      | Complete |
| Monitoring Platform           | Complete |
| Centralized Logging           | Complete |
| Alerting Platform             | Complete |
| Infrastructure as Code        | Complete |
| Recovery Testing              | Complete |
| Documentation Standardization | Complete |

---

## Current Environment Status

```text
Stable Operational Environment
```

### Capabilities

* Virtualization
* Containerization
* Monitoring
* Logging
* Alerting
* Infrastructure as Code
* Disaster Recovery
* Remote Administration
* Documentation

---

## Future Roadmap

### Planned Improvements

* Automated backup verification
* Enhanced observability dashboards
* Additional service integrations
* CI/CD workflow experimentation
* Infrastructure automation expansion
* Long-term metrics retention strategy
* Service health automation
* ESP32 telemetry integration

---

## Document Status

**Changelog Status:** Current

**Infrastructure State:** Operational

**Operational Readiness:** Validated

**Documentation Coverage:** Complete
