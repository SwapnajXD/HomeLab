# Infrastructure Changelog

## Purpose

This document records the major infrastructure changes, architectural decisions, and operational milestones throughout the evolution of the Olympus HomeLab.

It captures **what changed, why it changed, and the impact of those changes**, providing historical context for the platform's progression into a production-inspired infrastructure environment.

---

# Phase 10 — Log Aggregation Hardening (2026-07-05)

Extended the observability stack with centralized logging on top of the existing Prometheus/Grafana metrics stack.

## Added

- Loki 3.0 (filesystem storage, TSDB index, single-binary mode).
- Grafana Alloy as the log collector, replacing Promtail across the fleet.
- Loki datasource wired into Grafana, with working Explore queries (`{host="athena"}`).

## Known Issue (open)

Only the `grafana` and `loki` containers are currently being ingested; `prometheus`, `cadvisor`, `node-exporter`, `proxmox-exporter`, `portainer`, and `floci_aws` logs are not yet appearing. Root cause suspected to be an incomplete `discovery.docker`/`loki.source.docker` configuration in Alloy rather than a Loki or Grafana problem. See `postmortems.md` (2026-07-05) for full investigation notes.

---

# Phase 9.5 — Network Bring-up & Port Forwarding (2026-06-30)

Configured Apollo (Proxmox host) to provide outbound internet access to the isolated `10.10.10.0/24` VM network and to forward external connections to Hestia.

## Added

- Outbound NAT (`MASQUERADE`) from `10.10.10.0/24` through Apollo's Wi-Fi uplink.
- DNAT port forwarding: Apollo `:3000` → Hestia Homepage, Apollo `:8080` → Hestia Vaultwarden.

## Fixed

Diagnosed a Vaultwarden "unreachable" report that was actually an application-layer protocol mismatch — Vaultwarden serves HTTPS internally (`ROCKET_TLS`), and the client was connecting over plain HTTP. No networking change was required; connecting via `https://` resolved it. Full walkthrough in `postmortems.md` (2026-06-30).

---

# Phase 9 — Kubernetes Lab & Dashboard Build/Rollback (2026-06-11 → 2026-06-27)

Full dated build log, every incident encountered, and every fix applied for this phase — including the K3s cluster stand-up, the Athena network outage, the media-pipeline cron/JSON bugs, and the custom Homepage widget being built and later torn out in favor of a more maintainable integration — now lives in **`postmortems.md`**. Summary below.

A major architectural milestone introducing Kubernetes, and a dashboard backend that was ultimately decommissioned (see Phase 11).

## Added

### K3s Kubernetes Cluster

- Deployed a single-node K3s cluster on Athena.
- Enabled cgroup v2 support for compatibility with modern Kubernetes.
- Configured secure remote administration from Artemis using `kubectl`.
- Integrated Portainer for graphical Kubernetes management.

### Olympus Dashboard V2 *(later fully removed — see Phase 11)*

The dashboard architecture was redesigned around a centralized backend.

Changes included:

- Migrated all data collection from Hestia to Athena.
- Introduced a FastAPI-based Dashboard API.
- Established Athena as the single source of truth.
- Decoupled backend processing from frontend presentation.

### Dashboard Improvements *(later fully removed — see Phase 11)*

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

# Phase 11 — Dashboard API Decommission (2026-07-10)

Following on from the widget rollback in Phase 9, the entire Dashboard API concept was removed for good.

## Removed

- FastAPI Dashboard API container and image on Athena.
- All fetch scripts (LastFM, weather, prices, Pokémon, library, MyAnimeList, media/wallpaper) and their cron jobs.
- Any remaining custom Homepage integration code.

## Result

- Hestia now runs **Homepage in its stock, default configuration** — service links only, no custom widget, no backend dependency.
- Athena no longer runs any dashboard-related container, script, or scheduled job.
- Removes the small amount of ongoing maintenance risk the API represented, in exchange for a simpler, more reliable frontend.

## Rationale

Consistent with the lesson already learned in Phase 9: Homepage works best as a dashboard, not an application platform, and a backend is only worth keeping if something is still consuming it. See `postmortems.md` and `architecture.md` for the full history and current state.

---

# Operational Milestones

| Milestone | Status |
|-----------|--------|
| Virtualization Platform | Complete |
| Secure Remote Administration | Complete |
| Core Services | Complete |
| Observability Stack | Complete |
| Centralized Logging | Complete (partial log discovery — open) |
| Infrastructure as Code | Complete |
| Floci Migration | Complete |
| Kubernetes Deployment | Complete |
| Dashboard API | Decommissioned |
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
- Self-hosted applications (Homepage, Vaultwarden — stock configuration)
- Local AWS emulation
- Disaster recovery procedures
- Production-inspired documentation

---

# Future Roadmap

Planned areas of exploration include:

- Fixing Grafana Alloy's Docker log discovery gap
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

**Last Updated:** 2026-07-10

**Environment:** Stable Operational Environment

The Olympus HomeLab has evolved from a simple virtualization host into a production-inspired infrastructure platform featuring Kubernetes, centralized observability, Infrastructure as Code, secure remote administration, and comprehensive operational documentation.

## Known Open Items (as of 2026-07-10)

- Loki/Alloy centralized logging is live but only ingesting 2 of 9 Docker containers on Athena; Docker log discovery in Alloy still needs to be fixed (see `postmortems.md`, `troubleshooting.md`).
- MyAnimeList (MAL) dashboard integration is moot — the dashboard itself has been removed (kept here only as historical context).
- Reading/library tracking automation is likewise moot following the dashboard removal.