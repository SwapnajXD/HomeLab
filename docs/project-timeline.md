# Project Lifecycle & Chronological Milestone Timeline

## Overview

This document chronicles the evolution of the homelab environment from a simple virtualization platform into a production-inspired infrastructure ecosystem focused on Site Reliability Engineering (SRE), observability, automation, incident response, and operational excellence.

The timeline captures not only what was built, but also why architectural decisions were made, how failures were addressed, and how the platform matured through iterative improvements.

---

# Phase 1: Virtualization Foundation & Compute Platform

## Milestone

Establishing the core infrastructure layer capable of hosting isolated workloads.

## Engineering Activities

* Installed Proxmox VE on the bare-metal server (**Apollo**).
* Configured storage and initialized the virtual bridge network (`vmbr0`).
* Created the Ubuntu Server virtual machine (**Athena**) for operations and observability workloads.
* Created the Alpine Linux container (**Hestia**) for lightweight application hosting.
* Installed Docker and Docker Compose within guest systems.

## Outcome

A stable virtualization platform capable of hosting independent services with clear separation of responsibilities and room for future expansion.

---

# Phase 2: Secure Remote Access & Zero-Trust Administration

## Milestone

Enabling secure administration without exposing infrastructure directly to the public internet.

## Engineering Activities

* Deployed Tailscale across:

  * Artemis
  * Apollo
  * Athena
* Enabled MagicDNS resolution.
* Standardized SSH administration over the Tailnet.
* Eliminated router port forwarding requirements.
* Established fully headless management workflows.

## Outcome

The environment became securely accessible from anywhere while maintaining a minimal attack surface.

---

# Phase 3: Core Service Deployment

## Milestone

Deploying foundational self-hosted services.

## Engineering Activities

### Homepage

* Centralized infrastructure dashboard.
* Service organization and visibility.
* Unified access point for applications.

### Vaultwarden

* Self-hosted password management.
* Persistent storage integration.
* Secure credential management.

### Portainer

* Container visibility.
* Simplified service administration.
* Operational troubleshooting support.

## Outcome

Core services became available through centralized management interfaces, improving usability and operational efficiency.

---

# Phase 4: Monitoring, Metrics & Alerting

## Milestone

Transitioning from reactive operations to observable infrastructure.

## Engineering Activities

### Metrics Collection

* Prometheus
* Node Exporter
* Proxmox Exporter

### Visualization

* Grafana dashboards for:

  * Host monitoring
  * VM monitoring
  * Capacity planning
  * Resource utilization

### Alerting

* Grafana Alerting
* Telegram notifications

## Architecture

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
Telegram Alerting
```

## Outcome

Infrastructure health became measurable in real time with proactive notifications for critical events.

---

# Phase 5: Centralized Logging

## Milestone

Implementing searchable, centralized log aggregation.

## Engineering Activities

* Deployed Loki.
* Initially implemented Promtail.
* Later migrated to Grafana Alloy.
* Configured Docker log collection.
* Integrated logs into Grafana Explore.

## Architecture

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

## Outcome

Application and infrastructure logs became centrally searchable, accelerating troubleshooting and root-cause analysis.

---

# Phase 6: Infrastructure as Code & Local Cloud Experimentation

## Milestone

Introducing declarative infrastructure workflows.

## Engineering Activities

### LocalStack

Implemented local AWS-compatible services:

* S3 emulation
* DynamoDB emulation

### Terraform

Provisioned:

```text
tf-homelab-storage-bucket
tf-homelab-metadata
```

using repeatable Terraform workflows.

## Outcome

Infrastructure provisioning became reproducible, enabling safe experimentation with cloud-native patterns at zero cloud cost.

---

# Phase 7: Reliability Engineering & Platform Refactoring

## Milestone

Improving maintainability, efficiency, and operational resilience.

## Engineering Activities

### Telemetry Consolidation

Reorganized fragmented services into standardized stacks:

```text
docker-compose/
├── telemetry/
├── core-services/
└── localstack/
```

### Logging Modernization

* Migrated from Promtail to Grafana Alloy.
* Simplified log collection.
* Reduced configuration complexity.

### Operational Validation

Performed and documented:

* Headless administration testing.
* Guest autostart validation.
* Hypervisor reboot testing.
* Service recovery testing.
* Terraform destroy/rebuild validation.

## Outcome

Operational confidence improved significantly through repeatable procedures and simplified service management.

---

# Phase 7.5: Major Incidents & Operational Learning

## Milestone

Using real failures to strengthen platform reliability.

---

## Apollo Network Isolation Incident

### Incident

Following a Proxmox reboot, all internal workloads lost internet access and remote administration capabilities.

### Impact

* Tailscale became unreachable.
* DNS resolution failed.
* SSH sessions stalled.
* External connectivity disappeared.

### Root Cause

The outbound NAT masquerading rule responsible for translating traffic from the internal bridge network was not persistent across reboots.

Missing rule:

```bash
iptables -t nat -A POSTROUTING \
  -s 10.10.10.0/24 \
  -o wlx002e2df0393b \
  -j MASQUERADE
```

### Resolution

* Identified packet drops at the hypervisor boundary.
* Restored the NAT rule manually.
* Verified Tailscale recovery.
* Restored DNS functionality.
* Re-established remote administration.

### Lessons Learned

* Validate persistence of critical networking rules.
* Include NAT verification in recovery procedures.
* Preserve incident knowledge through post-mortems.

---

## Homepage Weather Integration Failure

### Incident

Homepage weather widgets experienced recurring TLS failures with Open-Meteo.

### Resolution

* Removed the unstable native widget.
* Implemented a custom shell integration using `wttr.in`.
* Cached responses locally for dashboard rendering.

### Lessons Learned

* Prefer resilient integrations.
* Introduce graceful degradation mechanisms.

---

## Loki Single-Node Deployment Failures

### Incident

Loki readiness probes failed due to distributed defaults unsuitable for standalone deployments.

### Resolution

Configured Loki explicitly for single-node operation:

```yaml
replication_factor: 1

kvstore:
  store: inmemory
```

### Lessons Learned

* Distributed defaults are not always appropriate.
* Simplicity improves reliability.

---

## Outcome

The platform evolved from merely hosting services to operating them with production-inspired incident response practices.

---

# Phase 8: SRE Documentation & Operational Excellence

## Milestone

Transforming the homelab into a maintainable and portfolio-ready engineering environment.

## Documentation Produced

### Architecture

* architecture.md
* network.md

### Operations

* operations-runbook.md
* disaster-recovery.md

### Incident Management

* incident-log.md
* post-mortem register

### Validation & Governance

* validation-report.md
* changelog.md
* inventory.md
* project-timeline.md

## Repository Improvements

* Standardized document structure.
* Improved maintainability.
* Reduced operational knowledge loss.
* Increased onboarding clarity.
* Established documentation-first practices.

## Outcome

The homelab matured into a fully documented operational platform resembling small-scale production environments.

---

# Current State

```text
Stable Operational Environment
```

## Active Capabilities

* Virtualization
* Containerization
* Monitoring
* Centralized Logging
* Alerting
* Secure Remote Administration
* Infrastructure as Code
* Incident Response
* Disaster Recovery
* Validation Testing
* Operational Documentation

---

# Future Roadmap

## Infrastructure

* Automated backup verification.
* Additional self-hosted services.
* Expanded Grafana dashboards.
* Enhanced observability coverage.

## Security

* Tailscale ACL implementation.
* Device tagging.
* Access segmentation.

## Automation

* CI/CD experimentation.
* Service health automation.
* Infrastructure automation improvements.

## Learning Projects

* ESP32 telemetry integration.
* Expanded Terraform workflows.
* Additional Floci service experimentation.
* Further cloud-native development exercises.

---

# Timeline Summary

| Phase | Milestone                                            | Status   |
| ----- | ---------------------------------------------------- | -------- |
| 1     | Virtualization Foundation & Compute Platform         | Complete |
| 2     | Secure Remote Access & Zero-Trust Administration     | Complete |
| 3     | Core Service Deployment                              | Complete |
| 4     | Monitoring, Metrics & Alerting                       | Complete |
| 5     | Centralized Logging                                  | Complete |
| 6     | Infrastructure as Code & Local Cloud Experimentation | Complete |
| 7     | Reliability Engineering & Platform Refactoring       | Complete |
| 7.5   | Major Incidents & Operational Learning               | Complete |
| 8     | SRE Documentation & Operational Excellence           | Complete |

---

# Project Status

**Current Phase:** SRE Documentation & Operational Excellence

**Infrastructure State:** Stable Operational Environment

**Operational Readiness:** Validated

**Documentation Coverage:** Comprehensive

**Overall Status:** Production-Inspired Homelab Platform
