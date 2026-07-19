# Project Timeline

## Overview

This document provides a chronological record of the Olympus HomeLab's evolution from a basic virtualization platform into a production-inspired infrastructure focused on Site Reliability Engineering (SRE), observability, automation, and cloud-native technologies.

Each phase documents the major architectural decisions, deployments, incident-driven improvements, and operational milestones that shaped the environment. For the full dated, incident-by-incident write-up (what broke, root cause, and fix) behind Phases 9 and 10, see `postmortems.md`.

---

# Phase 1 — Infrastructure Foundation

**Period:** Initial Build

## Objectives

- Build a stable virtualization platform.
- Establish isolated compute resources.
- Prepare the environment for future expansion.

## Milestones

### Apollo Hypervisor

- Installed Proxmox VE.
- Configured storage and networking.
- Created the primary bridge (`vmbr0`).

### Virtual Infrastructure

Created the core infrastructure nodes:

| Node | Purpose |
|-------|----------|
| Apollo | Proxmox Hypervisor |
| Athena | Ubuntu Server Operations VM |
| Hestia | Alpine Linux Application Container |

### Platform Setup

Installed:

- Docker
- Docker Compose

Configured:

- Internal networking
- VM communication
- Storage allocation

## Outcome

A stable virtualization platform capable of hosting independent workloads and future infrastructure services.

---

# Phase 2 — Secure Remote Administration

**Objective**

Enable secure, headless administration without exposing services directly to the public Internet.

## Engineering Activities

- Deployed Tailscale.
- Connected:
  - Artemis
  - Apollo
  - Athena
- Enabled MagicDNS.
- Standardized SSH access through the Tailnet.
- Eliminated router port forwarding.

## Outcome

Remote administration became secure, reliable, and available from anywhere.

---

# Phase 3 — Core Service Deployment

**Objective**

Deploy the first production-like self-hosted applications.

## Homepage

Implemented:

- Central dashboard
- Service categorization
- Widget support

## Vaultwarden

Implemented:

- Self-hosted password management
- Persistent storage
- Secure credential management

## Portainer

Implemented:

- Docker management
- Container monitoring
- Runtime inspection

## Outcome

The HomeLab gained a centralized operational interface for daily administration.

---

# Phase 4 — Monitoring & Observability

**Objective**

Introduce infrastructure monitoring and proactive visibility.

## Metrics Stack

Deployed:

- Prometheus
- Node Exporter
- Proxmox Exporter

## Visualization

Implemented Grafana dashboards for:

- CPU
- Memory
- Storage
- Network
- Virtual Machines

## Alerting

Configured:

- Grafana Alerting
- Telegram notifications

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
Telegram
```

## Outcome

Infrastructure health became continuously observable with real-time monitoring and alerting.

---

# Phase 5 — Centralized Logging

**Objective**

Implement centralized log aggregation.

## Initial Deployment

Installed:

- Loki
- Promtail

Later migrated to:

- Grafana Alloy

## Logging Pipeline

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

Logs became searchable from a single interface, significantly improving troubleshooting and root-cause analysis.

---

# Phase 6 — Infrastructure as Code

**Objective**

Introduce declarative infrastructure management.

## Local Cloud Platform

Initially deployed:

- LocalStack

Later migrated to:

- Floci

Benefits:

- Faster startup
- Lower memory usage
- Persistent mode
- Improved AWS compatibility

## Terraform

Provisioned AWS-compatible resources:

- S3 bucket
- DynamoDB table

Resources:

```text
tf-homelab-storage-bucket
tf-homelab-metadata
```

## Outcome

Infrastructure provisioning became repeatable, reproducible, and version-controlled.

---

# Phase 7 — Platform Refactoring & Reliability Engineering

**Objective**

Improve maintainability, operational reliability, and deployment consistency.

## Repository Refactoring

Standardized Docker Compose layout:

```text
docker-compose/
├── telemetry/
├── core-services/
└── floci/
```

## Telemetry Consolidation

Migrated from:

- Promtail

to

- Grafana Alloy

Benefits:

- Simpler configuration
- Better Docker discovery
- Lower resource usage

## Secure Synchronization

Configured passwordless Ed25519 SSH between Athena and Hestia.

Enabled:

- Automated synchronization
- Cron-based data replication
- Dashboard updates

## Validation

Performed:

- Hypervisor reboot testing
- Guest autostart testing
- Headless administration testing
- Terraform lifecycle testing
- Service recovery validation

## Outcome

The platform became significantly easier to maintain while improving resilience and operational confidence.

---

# Phase 8 — Documentation & Operational Standardization

**Objective**

Adopt production-inspired documentation and operational practices.

## Documentation Suite

Created:

- architecture.md
- network.md
- inventory.md
- runbook.md
- troubleshooting.md
- disaster-recovery.md
- validation-report.md
- changelog.md
- project-timeline.md
- health-checks.md

## Improvements

- Standardized Markdown formatting.
- Consistent repository structure.
- Documentation-first workflow.
- Operational procedures documented.
- Disaster recovery formalized.

## Outcome

The HomeLab matured into a fully documented and maintainable engineering platform suitable for long-term operation and portfolio presentation.

---

# Phase 9 — Kubernetes Lab & Dashboard V2

**Period:** 2026-06-11 → 2026-06-27

## Objectives

- Stand up a K3s cluster on Athena, manageable remotely from Artemis.
- Rebuild the Olympus dashboard around a centralized FastAPI backend instead of frontend-local scripts.

## Milestones

- **2026-06-17:** Decision made to move all dashboard data collection to Athena; Hestia becomes presentation-only.
- **2026-06-21:** K3s stood up on Athena (cgroup v2 enabled, remote `kubectl` access from Artemis over the LAN IP, Portainer Agent integrated).
- **2026-06-21 → 06-22:** Athena briefly dropped off the Tailnet due to a transient upstream network interruption; fully recovered with no configuration changes (full postmortem in `postmortems.md`).
- **2026-06-21:** Olympus V2 backend build — wallpaper engine, LastFM integration, cron automation, MAL widget attempt.
- **2026-06-18 → 06-27:** Full command-center build on top of Homepage; the custom `custom.js`/`custom.css` widget was ultimately judged too fragile (broke on mobile, tightly coupled to Homepage internals) and was torn out in favor of the more maintainable API-driven integration reflected in `architecture.md` today.

## Outcome

A working K3s lab with remote management (no Ingress controller deployed, confirmed during the 2026-07-18 audit), and a Dashboard API backend on Athena that survived this round of the widget rewrite/rollback cycle — though it was later decommissioned from active deployment, with its code retained in the repo (see Phase 11). Every incident, root cause, and fix from this phase is logged in detail in **`postmortems.md`**.

---

# Phase 10 — Network Bring-up & Observability Hardening

**Period:** 2026-06-26 → 2026-07-05

## Milestones

- **2026-06-26:** LastFM/media-pipeline cron overlap and GitHub API rate-limit crash resolved with `flock` locking, `jq` response validation, and wallpaper fallback logic.
- **2026-06-30:** Apollo configured for outbound NAT and DNAT port forwarding to Hestia (Homepage, Vaultwarden); a "Vaultwarden unreachable" report was traced to an HTTP-vs-HTTPS protocol mismatch, not a networking fault.
- **2026-07-05:** Loki + Grafana Alloy deployed for centralized logging alongside the existing Prometheus/Grafana metrics stack; end-to-end log pipeline confirmed working, but Docker container discovery in Alloy was only picking up 2 of 9 running containers — open investigation at the time (resolved by 2026-07-18, see Phase 12).

## Outcome

The network layer is fully routable and forwarded, and centralized logging exists end-to-end. Full incident detail in `postmortems.md`.

---

# Phase 11 — Dashboard API Decommission

**Date:** 2026-07-10

## What happened

The entire Olympus Dashboard API concept — the FastAPI backend on Athena, its fetch scripts, and their cron jobs — was decommissioned from active deployment. Hestia's Homepage instance now runs in a stock-plus-lightweight-theme configuration with no custom data widget and no backend dependency. **The Dashboard API's source code was intentionally retained in the repository** rather than deleted, as a portfolio artifact.

## Outcome

This closes out the dashboard experiment that ran through Phases 9 and part of the widget rollback: the frontend widget's logic was retired first (2026-06-27), and the backend it had been decoupled from was retired from deployment afterward. The homelab's frontend is now intentionally minimal in production, while the underlying engineering work remains visible in the repository. See `architecture.md` for the current state and `changelog.md` (Phase 11) / `postmortems.md` for the full rationale.

---

# Phase 12 — Live Infrastructure Audit & nftables Migration

**Date:** 2026-07-18 (audit); nftables migration ongoing

## What happened

A full live audit was run against Apollo, Athena, and Hestia to reconcile documentation with actual running systems — real container inventories, K3s cluster state, Tailscale mesh membership, NAT rules, and hardware specs were all captured directly from the hosts rather than assumed from prior docs. Separately, Apollo's NAT/firewall layer began a migration from `iptables` to `nftables`.

## Key Findings

- Hestia and Athena both run more services than previously documented (Hestia: Alloy, Node Exporter, Portainer Agent; Athena: cAdvisor, Glances).
- The Docker log discovery gap from Phase 10 is resolved — full ingestion confirmed across both hosts.
- Traefik is not deployed in K3s, correcting earlier documentation.
- Floci runs on-demand, not continuously.
- No `.env` files exist anywhere; all configuration is inline in Compose files.
- Real hardware specs for Apollo captured for the first time.
- A handful of small open items surfaced: an orphaned Portainer Compose project, a `k3s.yaml` permissions caveat, an asymmetric NAT return-path rule, and low-priority Docker DNS resolver noise.

## Outcome

The full documentation set (`inventory.md`, `architecture.md`, `network.md`, `troubleshooting.md`, `disaster-recovery.md`, `health-checks.md`, `validation-report.md`) was updated to match live reality. Full findings in `postmortems.md` (2026-07-18). The `nftables` migration remains in progress and will get its own follow-up entry once complete.

---

