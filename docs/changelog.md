# Infrastructure Changelog

## Purpose

This document records the major infrastructure changes, architectural decisions, and operational milestones throughout the evolution of the Olympus HomeLab.

It captures **what changed, why it changed, and the impact of those changes**, providing historical context for the platform's progression into a production-inspired infrastructure environment.

---

# Phase 9 — Kubernetes & Dashboard V2 (June 2026)

A major architectural milestone introducing Kubernetes and a centralized dashboard backend.

## Added

### K3s Kubernetes Cluster

- Deployed a single-node K3s cluster on Athena.
- Enabled cgroup v2 support for compatibility with modern Kubernetes.
- Configured secure remote administration from Artemis using `kubectl`.
- Integrated Portainer for graphical Kubernetes management.

### Olympus Dashboard V2

The dashboard architecture was redesigned around a centralized backend.

Changes included:

- Migrated all data collection from Hestia to Athena.
- Introduced a FastAPI-based Dashboard API.
- Established Athena as the single source of truth.
- Decoupled backend processing from frontend presentation.

### Dashboard Improvements

- LastFM album artwork support
- Pokémon species descriptions
- Hero panel media prioritization
- Safe JSON generation using `jq`
- Improved widget reliability

---

## Fixed

### Network Persistence

Resolved loss of NAT and port forwarding rules after Apollo reboot by implementing persistent networking configuration.

### Vaultwarden Access

Resolved HTTP/HTTPS protocol mismatch causing `400 Bad Request` responses.

### Automation Reliability

Added `flock` to scheduled fetch jobs to eliminate overlapping cron executions and race conditions.

---

# Phase 8 — Documentation & Operational Standardization

Infrastructure documentation was redesigned to follow production-oriented engineering practices.

## Added

- Architecture documentation
- Network documentation
- Operations runbook
- Disaster recovery procedures
- Troubleshooting knowledge base
- Validation reports
- Infrastructure inventory
- Project timeline
- Changelog

## Benefits

- Standardized operational procedures
- Improved maintainability
- Reduced knowledge loss
- Faster troubleshooting
- Portfolio-ready documentation

---

# Phase 7 — Platform Refactoring & Telemetry

Focused on simplifying the platform while improving observability.

## Added

### Grafana Alloy

Replaced Promtail with Grafana Alloy for centralized log collection.

### Floci

Migrated from LocalStack to Floci.

Benefits:

- Faster startup
- Lower memory usage
- Native AWS API compatibility
- Improved Terraform workflows

### Platform Improvements

- Passwordless Ed25519 SSH authentication
- Unified telemetry deployment
- Improved Docker Compose organization
- Single-node Loki optimization

---

## Fixed

- Apollo NAT persistence
- Docker container conflicts
- Loki readiness configuration
- File permission inconsistencies
- Legacy bridge cleanup

---

# Phase 6 — Infrastructure as Code

Infrastructure provisioning became reproducible through Terraform.

## Added

- Terraform workflows
- Local AWS emulation
- S3 bucket provisioning
- DynamoDB provisioning

### Managed Resources

- `tf-homelab-storage-bucket`
- `tf-homelab-metadata`

---

# Phase 5 — Observability Platform

Established centralized monitoring, logging, and alerting.

## Added

### Monitoring

- Prometheus
- Node Exporter
- Proxmox Exporter

### Visualization

- Grafana dashboards

### Logging

- Loki
- Grafana Alloy

### Alerting

- Grafana Alerting
- Telegram notifications

---

# Phase 4 — Core Services

Introduced user-facing applications.

## Added

- Homepage
- Vaultwarden
- Portainer

These services established the primary self-hosted application platform.

---

# Phase 3 — Secure Remote Administration

Implemented secure remote infrastructure management.

## Added

- Tailscale mesh networking
- MagicDNS
- Headless administration
- Secure SSH access

This eliminated the need for direct public management interfaces.

---

# Phase 2 — Virtual Infrastructure

Established the virtualized workload architecture.

## Added

- Athena (Ubuntu VM)
- Hestia (Alpine LXC)
- Docker
- Docker Compose
- Proxmox virtual networking

---

# Phase 1 — Foundation

The initial deployment of the homelab.

## Added

- Apollo Proxmox VE host
- Internal networking
- Storage configuration
- Base virtualization platform

This established the foundation for all future infrastructure development.

---

# Operational Milestones

| Milestone | Status |
|-----------|--------|
| Virtualization Platform | Complete |
| Secure Remote Administration | Complete |
| Core Services | Complete |
| Observability Stack | Complete |
| Centralized Logging | Complete |
| Infrastructure as Code | Complete |
| Floci Migration | Complete |
| Kubernetes Deployment | Complete |
| Dashboard V2 | Complete |
| Documentation Standardization | Complete |

---

# Current Environment

**Infrastructure State:** Stable Operational Environment

## Active Capabilities

- Proxmox virtualization
- Docker containerization
- K3s Kubernetes
- Centralized observability
- Infrastructure as Code
- Secure remote administration
- Self-hosted applications
- Dashboard API
- Local AWS emulation
- Disaster recovery procedures
- Production-inspired documentation

---

# Future Roadmap

Planned areas of exploration include:

- Automated backup validation
- Enhanced Grafana dashboards
- CI/CD experimentation
- Infrastructure automation
- Long-term metrics retention
- Service health automation
- Additional Kubernetes workloads
- ESP32 telemetry integration

---

# Current Status

**Last Updated:** June 2026

**Environment:** Stable Operational Environment

The Olympus HomeLab has evolved from a simple virtualization host into a production-inspired infrastructure platform featuring Kubernetes, centralized observability, Infrastructure as Code, secure remote administration, and comprehensive operational documentation.