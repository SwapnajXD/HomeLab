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

### Olympus Dashboard V2 *(later decommissioned from deployment — see Phase 11; code retained in repo)*

The dashboard architecture was redesigned around a centralized backend.

Changes included:

- Migrated all data collection from Hestia to Athena.
- Introduced a FastAPI-based Dashboard API.
- Established Athena as the single source of truth.
- Decoupled backend processing from frontend presentation.

### Dashboard Improvements *(later decommissioned from deployment — see Phase 11; code retained in repo)*

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

Following on from the widget rollback in Phase 9, the entire Dashboard API concept was decommissioned from active deployment.

## Decommissioned from Deployment (code retained in repo)

- FastAPI Dashboard API container and image on Athena — stopped, not deleted from the repository (`docker-compose/dashboard-api/`).
- All fetch scripts (LastFM, weather, prices, Pokémon, library, MyAnimeList, media/wallpaper) and their cron jobs — disabled, scripts retained (`scripts/fetch_*.sh`).
- Custom Homepage widget logic — `custom.js` emptied out.

## Result

- Hestia now runs **Homepage in a stock-plus-lightweight-theme configuration** — native service-discovery widgets, a purely cosmetic `custom.css`, no data widget, no backend dependency.
- Athena no longer runs any dashboard-related container or scheduled job.
- Removes the small amount of ongoing maintenance/operational risk the API represented, in exchange for a simpler, more reliable frontend — while keeping the actual engineering work visible in the repository.

## Rationale

Consistent with the lesson already learned in Phase 9: Homepage works best as a dashboard, not an application platform, and a backend is only worth *deploying* if something is still consuming it. Keeping the code in the repo (rather than deleting it) was a deliberate choice — it's real, working software worth having visible, separate from the decision not to run it in production. See `postmortems.md` and `architecture.md` for the full history and current state.

---

# Phase 12 — Live Infrastructure Audit & nftables Migration (2026-07-18)

## Live Infrastructure Audit

A full audit was run directly against Apollo, Athena, and Hestia to catch drift between documentation and actual running systems. Findings and full detail in `postmortems.md` (2026-07-18); summary:

- Hestia's and Athena's real container inventories were larger than documented (Hestia: + Alloy, Node Exporter, Portainer Agent; Athena: + cAdvisor, Glances).
- The Grafana Alloy Docker log discovery gap (open since 2026-07-05) is **resolved** — confirmed via live Loki query, all containers on both hosts now ingesting.
- Traefik confirmed **not** deployed in K3s, correcting earlier documentation.
- Floci confirmed to be an on-demand service, not always-running.
- Tailscale mesh confirmed to include a 4th device (personal Android phone, typically offline).
- No `.env` files exist anywhere — all config is inline in Compose files.
- Apollo's real hardware specs documented for the first time (AMD Ryzen 7 3700X, 16GB RAM, NVMe + SATA storage, an idle NVIDIA GTX 1660 Super).
- An orphaned Portainer Compose project (`core-services`, no matching compose file on disk) identified as a minor open item.

## nftables Migration (In Progress)

Apollo's NAT/firewall layer is being migrated from `iptables` to `nftables`. While preparing for this, a stale/incorrect duplicate MASQUERADE rule (bound to the wrong network interface) was found and cleaned up in the live `iptables` table — unrelated to the migration itself, just surfaced while working in the same area. Migration is ongoing; `network.md` and `inventory.md` will be updated with the `nftables` rule set once complete.

---

# Operational Milestones

| Milestone | Status |
|-----------|--------|
| Virtualization Platform | Complete |
| Secure Remote Administration | Complete |
| Core Services | Complete |
| Observability Stack | Complete |
| Centralized Logging | Complete — full container discovery confirmed |
| Infrastructure as Code | Complete |
| Floci Migration | Complete (on-demand usage) |
| Kubernetes Deployment | Complete (no Ingress controller deployed) |
| Dashboard API | Decommissioned from deployment — code retained |
| Documentation Standardization | Complete |
| Live Infrastructure Audit | Complete (2026-07-18) |
| nftables Migration | In Progress |


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

**Last Updated:** 2026-07-18

**Environment:** Stable Operational Environment

The Olympus HomeLab has evolved from a simple virtualization host into a production-inspired infrastructure platform featuring Kubernetes, centralized observability, Infrastructure as Code, secure remote administration, and comprehensive operational documentation — reconciled against a live infrastructure audit as of 2026-07-18.

## Known Open Items (as of 2026-07-18)

- Apollo's NAT/firewall layer migration from `iptables` to `nftables` is in progress.
- Orphaned `core-services` Compose project (Portainer, Athena) — no matching compose file on disk, needs to be written and committed.
- `k3s.yaml` permissions reset on every `k3s` service restart — workaround exists, not yet automated.
- Port 3000 return-path NAT rule is defined in config but not applied live — low priority.
- Recurring `dockerd` DNS resolver errors on Athena — informational, not yet investigated.
- MyAnimeList (MAL) dashboard integration and reading/library tracking automation are both moot — the dashboard itself has been decommissioned from deployment (kept here only as historical context; code retained in repo).