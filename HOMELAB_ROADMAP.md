# HOMELAB_ROADMAP.md

## Overview

This roadmap outlines the evolution of the HomeLab environment, highlights completed engineering milestones, identifies current development priorities, and captures future initiatives planned for continued learning and infrastructure maturity.

The objective is to maintain a clear direction for the platform while documenting the practical skills and operational capabilities developed throughout the project lifecycle.

---

# ✅ Completed Milestones

## 🏗️ Phase 1–5: Core Virtualization & Telemetry Foundation

### Bare-Metal Compute Platform
- Deployed **Proxmox VE** on the bare-metal host **Apollo**.
- Established the primary virtual bridge network (`vmbr0`).
- Created isolated execution environments for infrastructure workloads.

### Workload Isolation Architecture
- Provisioned **Athena** (Ubuntu Server VM) for monitoring, automation, and operational services.
- Provisioned **Hestia** (Linux Container) for user-facing applications.
- Installed Docker and Docker Compose within guest environments.

### Secure Remote Administration
- Connected infrastructure nodes using **Tailscale**:
  - Artemis
  - Apollo
  - Athena
- Enabled MagicDNS resolution.
- Standardized SSH-based headless administration.
- Eliminated public router port forwarding requirements.

### Core Service Deployment
Successfully deployed:

- Homepage
- Vaultwarden
- Portainer

Result:
- Centralized service visibility.
- Self-hosted credential management.
- Simplified container administration.

### Observability Foundation
Implemented a complete metrics and alerting stack:

#### Metrics Collection
- Prometheus
- Node Exporter
- Proxmox Exporter

#### Visualization
- Grafana dashboards

#### Alerting
- Grafana Alerting
- Telegram notifications

Metrics architecture:

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

Result:
- Real-time infrastructure visibility.
- Automated incident notifications.

---

# 🛠️ Phase 6–7: Reliability Engineering & Platform Optimization

## Telemetry Stack Consolidation

Restructured fragmented Docker deployments into a unified layout:

```text
docker-compose/
├── telemetry/
├── core-services/
└── localstack/
```

Benefits:

- Simplified operations.
- Reduced deployment complexity.
- Standardized maintenance workflows.
- Eliminated container naming conflicts.

---

## Logging Pipeline Modernization

Modernized the centralized logging stack by replacing Promtail with Grafana Alloy.

### Improvements

- Unified telemetry agent architecture.
- Improved Docker service discovery.
- Simplified configuration management.
- Reduced operational overhead.

Logging architecture:

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

Result:
- Centralized, searchable log aggregation.

---

## Reliability & Recovery Validation

Validated infrastructure resilience through controlled testing.

### Headless Operations

Confirmed complete management without:

- Monitor
- Keyboard
- Mouse

Using:

- Tailscale
- SSH
- Grafana
- Portainer
- Homepage

---

### Autostart Validation

Verified automatic startup of:

- Athena (VM 100)
- Hestia (LXC 101)

following Apollo reboot.

---

### Recovery Testing

Validated:

- Hypervisor reboot recovery
- VM recovery
- Container recovery
- Service recovery
- Tailscale reconnection
- Telemetry restoration

Result:

```text
Operational Readiness: VALIDATED
```

---

## Dashboard Data Architecture Improvements

Resolved intermittent external weather integration failures.

### Improvements

- Replaced unreliable direct integrations.
- Implemented local shell wrappers around `wttr.in`.
- Improved Homepage widget stability.

Result:

- Consistent weather updates.
- Improved dashboard reliability.

---

## Inter-Node Data Synchronization

Implemented secure synchronization between Athena and Hestia.

### Architecture

```text
Athena
    │
    ▼
Ed25519 SSH
    │
    ▼
Hestia
    │
    ▼
JSON Data Sync
    │
    ▼
Olympus Dashboard API
```

Features:

- Passwordless authentication.
- Automated cron execution.
- Five-minute synchronization intervals.
- Reliable dashboard data ingestion.

Result:

- Fully automated data distribution pipeline.

---

## Incident Response & Troubleshooting

### Apollo Networking Recovery

Successfully diagnosed and resolved a major networking outage following hypervisor reboot.

### Root Cause

Missing outbound NAT masquerading rules.

### Resolution

- Identified broken routing path.
- Restored iptables masquerading.
- Revalidated connectivity.

Validated services:

- Internet access
- Tailscale
- Docker workloads
- Monitoring pipelines

Result:

```text
Recovery procedures proven effective.
```

---

# ⚡ Active Engineering Focus (Phase 8)

## Homepage Dashboard Enhancement

Current objective:

Transform Homepage from a simple service directory into an operational command center.

### Planned Structure

```text
Olympus
Operations
Observability
Personal Feed
Resources
```

Goals:

- Improved usability.
- Logical grouping.
- Faster navigation.
- Better visual hierarchy.

---

## Olympus Dashboard API Expansion

Expanding the custom FastAPI service.

### Planned Endpoints

```text
GET /weather
GET /system
```

Purpose:

- Surface live operational data.
- Feed Homepage widgets directly.
- Reduce reliance on third-party integrations.

Expected outcome:

- Richer dashboard experiences.
- Greater control over displayed data.

---

# 🔮 Future Architecture Initiatives (Phase 9+)

## Reverse Proxy & Internal Routing

### Evaluation Candidates

- Caddy
- Traefik

### Objectives

Replace direct port references with friendly internal domains.

Target architecture:

```text
homepage.lab ──► 10.10.10.2:3000
vault.lab    ──► 10.10.10.2:8080
grafana.lab  ──► 10.10.10.10:3001
```

Benefits:

- Improved usability.
- Cleaner URLs.
- Internal TLS opportunities.
- Simplified access patterns.

---

## Synthetic Uptime Monitoring

### Planned Deployment

Uptime Kuma

### Objectives

- Availability monitoring.
- Latency tracking.
- Historical uptime reporting.
- Telegram integration.

Result:

- Independent validation of service health.

---

## CI/CD & GitOps Experimentation

### Evaluation Candidates

- Forgejo
- Gitea

### Objectives

Implement lightweight GitOps workflows.

Potential capabilities:

- Repository hosting.
- Webhook automation.
- Configuration deployment triggers.
- Change validation workflows.

Example triggers:

```text
services.yaml
prometheus.yml
homepage-config/
```

Result:

- Improved automation maturity.
- Hands-on GitOps experience.

---

## IoT Telemetry Integration

### Objective

Integrate physical sensors into the observability stack.

### Platform

ESP32 microcontrollers.

### Potential Metrics

- Temperature
- Humidity
- Environmental conditions
- Power usage

Architecture:

```text
ESP32 Sensors
        │
        ▼
Custom Exporters
        │
        ▼
Prometheus
        │
        ▼
Grafana
```

Result:

- Real-world telemetry ingestion.
- Expanded monitoring capabilities.
- Additional experimentation opportunities.

---

# Current Environment Status

```text
Stable Operational Environment
```

## Active Capabilities

- Virtualization
- Containerization
- Secure Remote Administration
- Monitoring
- Logging
- Alerting
- Infrastructure Validation
- Disaster Recovery
- Documentation
- Infrastructure as Code
- Automated Data Synchronization

---

# Roadmap Summary

| Phase | Focus Area | Status |
|---------|------------|----------|
| 1–5 | Foundation, Services, Observability | ✅ Complete |
| 6–7 | Reliability Engineering & Refactoring | ✅ Complete |
| 8 | Dashboard Enhancement & API Expansion | 🚧 In Progress |
| 9 | Reverse Proxy, Uptime, GitOps, IoT | 📋 Planned |

---

# Project Status

**Current Phase:** Dashboard Enhancement & API Expansion

**Infrastructure State:** Stable Operational Environment

**Operational Readiness:** Validated

**Documentation Coverage:** Comprehensive

**Overall Status:** Production-inspired HomeLab actively evolving through iterative improvement and experimentation.