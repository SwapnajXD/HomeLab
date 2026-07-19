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

> *(Correction, 2026-07-18 live audit: this folder was not renamed — `docker-compose/localstack/` and `docker-compose/floci/` both exist side by side on Athena today. LocalStack's compose file and prior data are kept on disk for reference but are not in active use; Floci is the current AWS emulator, started on-demand rather than continuously. See `docs/postmortems.md`.)*

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

> **Update:** this synchronization pipeline, along with the weather-widget fix above and the Olympus Dashboard API it fed, was decommissioned from active deployment on 2026-07-10 — its code was intentionally kept in the repository rather than deleted. See the note at the end of Phase 8 below.

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

# ⚡ Phase 8: Dashboard Enhancement & API Expansion *(Superseded — see outcome below)*

> **This phase did not go the way it was planned.** It's kept here as written at the time, followed by what actually happened, because the pivot is a more useful record than pretending the original plan was the final word.

## Original Plan (as written)

### Homepage Dashboard Enhancement

Objective at the time: transform Homepage from a simple service directory into an operational command center.

#### Planned Structure

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

### Olympus Dashboard API Expansion

Plan was to expand the custom FastAPI service with additional endpoints (`GET /weather`, `GET /system`) to surface more live operational data directly in Homepage widgets.

---

## What Actually Happened

Building on this plan surfaced the same problem repeatedly: the custom Homepage widget was fragile (broke on mobile — see `docs/postmortems.md`, 2026-06-18→27), tightly coupled to Homepage's internals, and every new endpoint added more surface area to maintain for a personal-dashboard feature that wasn't providing proportional value.

Instead of expanding it, the decision was made to:

1. **2026-06-27** — tear out the custom `custom.js`/`custom.css` widget and return Homepage to a stock configuration.
2. **2026-07-10** — go further and remove the FastAPI Dashboard API backend itself, along with every fetch script and cron job that fed it.

Homepage now runs standalone, in its stock configuration, with no backend dependency. K3s and the rest of the observability stack were unaffected by this — this was purely a frontend/API simplification.

**Lesson carried forward:** treat Homepage as a dashboard, not an application platform, and only keep a backend around while something is actually consuming it. Full history: `docs/postmortems.md`, `docs/changelog.md` (Phase 11).

---

# 🔮 Future Architecture Initiatives (Phase 9+)

> **Update:** since this roadmap was first written, a single-node **K3s Kubernetes cluster** has been stood up on Athena and is in active use, remotely managed from Artemis via `kubectl` (see `docs/postmortems.md`, 2026-06-21, and `docs/inventory.md`). It isn't listed as an item below because it's already done — the items below are what's still ahead.
>
> **Also resolved on 2026-07-18, not originally on this roadmap either:** a real internet outage on Apollo (stale NAT interface rule after a Wi-Fi/USB-tethering switch) led to evaluating a migration from `iptables` to `nftables`. It was **explicitly declined** — Apollo runs `iptables-legacy`, independent from `nftables`, and Tailscale/Docker/K3s already manage their own `iptables` chains, so migrating would have meant conflicting rule sets rather than fixing the actual bug. A dedicated, idempotent firewall script with dynamic WAN detection (`apollo-firewall.sh` + a `systemd` unit) shipped instead. See `docs/postmortems.md` for the full incident and decision record.

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

# 💡 Phase 10: Suggested Additions (Cloud & DevOps Skill Expansion)

> These are new — not yet started, not yet committed to. Since this homelab doubles as a resume project and a learning environment for cloud/DevOps, the suggestions below are grouped by the skill area they'd demonstrate, so you can pick what's most useful rather than trying to do all of it. Roughly ordered easiest/cheapest → more involved within each group.

## Configuration Management

Right now, node setup is manual/scripted ad hoc. Introducing a config management tool is one of the highest-value DevOps skills to show.

- **Ansible** — write playbooks for Apollo/Athena/Hestia base setup (packages, users, Docker install, Tailscale join). Turns "how Athena was configured" from tribal knowledge into something reproducible and reviewable in Git.
- Stretch goal: rebuild one node from bare Proxmox using only the playbook, timed, as a documented DR exercise.

## Secrets Management

Currently `.env` files and manual credentials appear to be the norm (reasonable for a homelab, but worth leveling up for the portfolio).

- **SOPS + age** — lightweight, Git-friendly encrypted secrets, easy to justify in a personal project.
- **HashiCorp Vault** (heavier, but resume-relevant) — dynamic secrets, audit logging; could run as another K3s workload once Persistent Volumes are in place.

## Kubernetes Maturity

K3s is running single-node; a few incremental steps would round this out nicely for interviews:

- **Persistent Volumes** (already on the roadmap) — pair with a real stateful workload (e.g., move Vaultwarden or a small Postgres instance into K3s) rather than leaving it theoretical.
- **Traefik (or another Ingress controller)** — a 2026-06-21 build session noted Traefik was "kept for learning Ingress," but a live audit (2026-07-18) confirmed it isn't actually deployed in the cluster. Worth either deploying it for real or updating the earlier note — right now the docs and the cluster disagree.
- **cert-manager** — issue internal TLS certs automatically for K3s-hosted services; pairs well with the planned reverse proxy work.
- **Helm** — package at least one workload as a chart instead of raw manifests; very commonly expected DevOps skill.
- Optional: add a second, even low-power node (e.g., a Raspberry Pi) to go from single-node to a real multi-node cluster and practice scheduling/affinity.

## CI/CD Depth

The roadmap already has GitOps (Argo CD/Flux) and a self-hosted Git server (Forgejo/Gitea) planned — worth adding the CI half explicitly:

- **Gitea Actions / Forgejo Actions** or a lightweight **self-hosted CI runner** — build/lint/test on push, not just deploy-on-merge.
- **Container image scanning** (Trivy or Grype) in that pipeline — cheap to add, directly relevant to security-conscious DevOps roles.
- **Pre-commit hooks** for Terraform (`terraform fmt`, `tflint`) and YAML/Markdown linting — small, but shows IaC hygiene.

## Backup & Disaster Recovery Automation

`disaster-recovery.md` documents manual recovery procedures well — automating a slice of it would be a strong addition:

- **Restic** or **Borg** scheduled backups of Vaultwarden data, Grafana dashboards, and Terraform state, pushed to an off-box target (Backblaze B2 is cheap and commonly used for homelabs).
- A scripted **restore drill** run periodically, with results logged — turns "we have a DR runbook" into "we test our DR runbook."

## Observability Maturity

The metrics/logging/alerting stack is solid; a few additions would make it feel more production-grade:

- **Uptime Kuma** (already planned) — pair it with alerting *cross-checks*: if Prometheus says a service is up but Uptime Kuma's external check disagrees, that's a more interesting signal than either alone.
- **SLOs/error budgets** — even informally, define one or two (e.g., "Homepage should respond in <500ms, 99% of the time") and track it in Grafana. This is a very interview-friendly SRE concept to be able to speak to from a real project.
- ~~Finish the open Grafana Alloy Docker log discovery issue~~ — **resolved**, confirmed via live audit 2026-07-18 (all 12 running containers across both hosts now ingesting correctly).

## Cloud Practice (actual cloud, not just Floci)

Floci is great for free local AWS-API practice, but pairing it with a small amount of **real** cloud usage would round out the "cloud" half of "cloud and DevOps":

- Stand up one genuinely tiny always-free-tier resource (e.g., an AWS S3 bucket + IAM user via Terraform, or an Oracle Cloud free-tier VM) so at least one Terraform workflow targets real cloud, not just Floci.
- Mirror one existing Terraform module to also support a real provider as an optional backend, documented as "local dev against Floci, deploy against real AWS."

## Hardware Utilization (new — surfaced by the 2026-07-18 hardware audit)

Apollo has real, currently-idle capacity worth putting to use:

- **GPU passthrough** — the NVIDIA GTX 1660 Super is present but unused (`nouveau` driver, no passthrough configured). Passing it through to a guest would enable either Jellyfin/Plex hardware transcoding or a small local LLM/ML experimentation VM — both are legitimate, resume-relevant uses of hardware that's otherwise sitting idle.
- **RAM headroom** — only 1 of 4 DIMM slots is populated (16GB installed). Worth keeping in mind before any capacity-constrained decision (e.g., adding a second K3s node) gets ruled out prematurely.

## Cost & FinOps Awareness (lightweight)

Not urgent for a homelab, but a nice differentiator on a resume aimed at cloud/DevOps roles:

- **Infracost** in the Terraform pipeline once real-cloud resources exist, to show cost-awareness as a habit, not just an afterthought.

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
- Kubernetes (K3s)

---

# Roadmap Summary

| Phase | Focus Area | Status |
|---------|------------|----------|
| 1–5 | Foundation, Services, Observability | ✅ Complete |
| 6–7 | Reliability Engineering & Refactoring | ✅ Complete |
| 8 | Dashboard Enhancement & API Expansion | ⤴️ Superseded — pivoted to decommission from deployment (2026-07-10) instead, code retained |
| — | K3s Kubernetes Lab | ✅ Complete (built 2026-06-21, not originally in this roadmap; no Ingress deployed) |
| — | Centralized Logging (Loki + Grafana Alloy) | ✅ Complete — full container discovery confirmed 2026-07-18 |
| — | Live Infrastructure Audit | ✅ Complete (2026-07-18) — see `docs/postmortems.md` |
| — | `iptables` → `nftables` Migration | ✅ Resolved — evaluated and explicitly declined; dynamic firewall script shipped instead |
| 9 | Reverse Proxy, Uptime, GitOps, IoT | 📋 Planned |
| 10 | Suggested: Config Mgmt, Secrets, K8s Maturity, CI/CD Depth, Backup Automation, SLOs, Real-Cloud Practice, Hardware Utilization, FinOps | 💡 Suggested — not yet started |

---

# Project Status

**Current Phase:** Post-audit reconciliation — documentation now matches live infrastructure, including the resolved Apollo networking/firewall rework; Phase 9/10 items are next up.

**Infrastructure State:** Stable Operational Environment

**Operational Readiness:** Validated (last confirmed against live systems 2026-07-18)

**Documentation Coverage:** Comprehensive

**Overall Status:** Production-inspired HomeLab actively evolving through iterative improvement, experimentation, and — just as importantly — deliberately retiring things from production that stopped earning their complexity, while keeping the underlying engineering visible.

---

# Roadmap Revision Notes

**Last Reviewed:** 2026-07-18 (live infrastructure audit)

This roadmap was written early in the project and has been reviewed against the current state of the environment (`docs/architecture.md`, `docs/changelog.md`, `docs/postmortems.md`) — most recently cross-checked against a live audit run directly on Apollo, Athena, and Hestia. Key drift found and corrected:

- Phase 8 planned to *expand* the Olympus Dashboard API; the actual outcome was the opposite — the widget's logic was rolled back (2026-06-27) and the API itself was later decommissioned from active deployment (2026-07-10). **Its source code was intentionally kept in the repository**, not deleted. Marked as superseded above rather than silently deleted, since the reasoning behind the reversal is useful history.
- K3s Kubernetes wasn't in this roadmap at all when originally written but has since been built and is in active use — added above as a completed, unplanned addition. A live audit also confirmed Traefik, despite being noted as "kept" in an earlier build log, isn't actually deployed.
- The `docker-compose/localstack/` folder referenced under Phase 6–7 was **not** actually renamed to `floci/` as this document previously claimed — a live audit found both folders still exist side by side, with LocalStack's data kept on disk but unused. Corrected in place above.
- Everything else in Phase 9 (reverse proxy, Uptime Kuma, GitOps, IoT telemetry) still reflects genuine, unstarted future work and was left as-is.
- Added Phase 10 as a set of new suggestions (config management, secrets, Kubernetes maturity, CI/CD depth, backup automation, SLOs, real-cloud practice, hardware utilization, lightweight FinOps) aimed specifically at rounding out the cloud/DevOps skill story for a resume-facing project. None of it is committed — it's there to pick from.
- **2026-07-18 update:** a full live-infrastructure audit closed out the previously-open Grafana Alloy logging gap (now resolved, confirmed via direct Loki query), surfaced real hardware specs for Apollo (AMD Ryzen 7 3700X, 16GB RAM, an idle NVIDIA GTX 1660 Super), and corrected the Hestia/Athena service inventories (both were running more than documented). The audit also surfaced a real internet outage on Apollo (stale NAT interface rule), which led to evaluating — and explicitly declining — a migration from `iptables` to `nftables` in favor of a dedicated, idempotent firewall script with dynamic WAN detection. None of this was part of any prior roadmap phase. Full findings in `docs/postmortems.md`.