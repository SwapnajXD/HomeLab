# Olympus HomeLab

![Platform](https://img.shields.io/badge/platform-Proxmox%20VE-blue)
![OS](https://img.shields.io/badge/os-Ubuntu%20%7C%20Alpine-orange)
![Containers](https://img.shields.io/badge/containers-Docker-blue)
![Orchestration](https://img.shields.io/badge/orchestration-K3s-326CE5)
![IaC](https://img.shields.io/badge/IaC-Terraform-7B42BC)
![Monitoring](https://img.shields.io/badge/monitoring-Grafana%20%7C%20Prometheus-green)
![Logging](https://img.shields.io/badge/logging-Loki%20%7C%20Grafana%20Alloy-yellow)
![Remote](https://img.shields.io/badge/remote-Tailscale-blue)
![Status](https://img.shields.io/badge/status-Fully%20Validated-brightgreen)

A production-inspired self-hosted HomeLab built on **Proxmox VE** for learning modern infrastructure engineering, Site Reliability Engineering (SRE), Kubernetes, observability, Infrastructure as Code, automation, and disaster recovery.

The environment is designed around a layered architecture where infrastructure, operations, and frontend services are separated into dedicated nodes. It is fully manageable through **Tailscale** and documented with production-style operational procedures — including the incidents encountered along the way and how they were resolved (see [`docs/postmortems.md`](docs/postmortems.md)).

---

# Architecture

```
                    Artemis
           (Management Workstation)
                    │
             Tailscale Mesh (4 nodes)
                    │
                Apollo
        Proxmox VE 9.2.2 Hypervisor
     (Ryzen 7 3700X · 16GB RAM)
                    │
      ┌─────────────┴─────────────┐
      │                           │
 VM 100: Athena             CT 101: Hestia
 Ubuntu Operations VM      Alpine Frontend LXC
 (Tailscale-connected)     (isolated — reached
      │                     via Apollo DNAT)
 Docker + K3s                    │
      │                    Docker Compose
 Grafana                         │
 Prometheus                 Homepage (stock + theme)
 Loki                       Vaultwarden
 Grafana Alloy              Grafana Alloy
 cAdvisor / Glances         Node Exporter
 Portainer                  Portainer Agent
 Floci (on-demand)
```

Full Mermaid diagrams (rendered natively on GitHub): [`architecture/architecture-diagram.mmd`](architecture/architecture-diagram.mmd) and the rest of the [`architecture/`](architecture/) directory.

---

# Infrastructure Overview

## Apollo

**Role:** Proxmox VE 9.2.2 Hypervisor

**Hardware:** AMD Ryzen 7 3700X (8c/16t), 16GB DDR4-3200, 238.5GB NVMe (LVM-thin pool) + 232.9GB SATA storage, idle NVIDIA GTX 1660 Super (no passthrough — a real future upgrade candidate).

Responsibilities:

- Virtualization
- Storage Management
- Virtual Networking
- Persistent NAT Gateway
- Port Forwarding

> Apollo's NAT/firewall layer runs as a dedicated, idempotent script (`apollo-firewall.sh` + a `systemd` unit) with dynamic WAN detection — a migration to `nftables` was evaluated and explicitly declined. See [`docs/postmortems.md`](docs/postmortems.md) (2026-07-18) for the full story.

---

## Athena (VM 100)

**Role:** Operations & Kubernetes Platform

Hosted Services:

- Grafana
- Prometheus
- Loki
- Grafana Alloy
- Node Exporter
- Proxmox Exporter
- cAdvisor
- Glances
- Portainer
- Floci — **started on-demand**, not always running
- K3s Kubernetes Cluster (no Ingress controller deployed)

---

## Hestia (CT 101)

**Role:** Frontend Platform

Hosted Services:

- Homepage — stock service-discovery widgets + a lightweight, purely visual `custom.css` theme
- Vaultwarden
- Grafana Alloy — per-host log collection
- Node Exporter — per-host metrics
- Portainer Agent — lets Athena's central Portainer manage Hestia remotely

> Hestia is intentionally excluded from the Tailscale mesh and reachable only through Apollo's port forwarding.

---

## Artemis

**Role:** Management Workstation

Used for:

- SSH Administration
- kubectl Management
- Terraform
- Git Operations
- Documentation

---

# Features

- Proxmox-based virtualized infrastructure
- Docker Compose service orchestration
- Single-node K3s Kubernetes cluster, remotely managed via `kubectl`
- Secure remote administration with Tailscale
- Centralized metrics using Prometheus
- Centralized logging using Loki & Grafana Alloy
- Grafana dashboards and alerting
- Telegram alert notifications
- Infrastructure as Code with Terraform
- Local AWS emulation using Floci
- Minimal, low-maintenance Homepage frontend
- Disaster Recovery Runbook
- Operational Runbook
- Infrastructure Validation Reports
- Health Verification Procedures
- Dated incident/postmortem log
- Production-style documentation

---

# Technology Stack

## Infrastructure

- Proxmox VE
- Ubuntu Server
- Alpine Linux
- Docker
- Docker Compose
- LXC

## Kubernetes

- K3s
- kubectl
- Portainer

## Networking

- Tailscale
- Linux Bridge (`vmbr0`)
- iptables NAT
- DNAT Port Forwarding

## Observability

- Grafana
- Prometheus
- Loki
- Grafana Alloy
- Node Exporter
- Proxmox Exporter

## Automation

- Bash
- Cron
- flock
- jq

## Infrastructure as Code

- Terraform
- Floci
- AWS CLI

## Frontend

- Homepage (stock configuration)
- Vaultwarden

---

# A Note on the Dashboard

Earlier in the project, Homepage was extended into a custom "Olympus" command-center widget, backed by a dedicated FastAPI aggregation service on Athena (LastFM, weather, Pokémon, investments, and more). It worked, but it turned out to be more maintenance than it was worth — tightly coupled to Homepage's internals, fragile across devices, and only earning its complexity while something was actively consuming it.

Both the widget's logic and its backend API have been **decommissioned from active deployment** — Homepage now runs in a stock-plus-lightweight-theme configuration. The source code for both is **intentionally retained in the repository** (`docker-compose/dashboard-api/`, `scripts/fetch_*.sh`) rather than deleted — it's real, working engineering worth having visible, separate from the decision not to run it in production. The full build-it, learn-from-it, retire-it-from-deployment story — including every incident and fix along the way — is documented in [`docs/postmortems.md`](docs/postmortems.md) and [`docs/changelog.md`](docs/changelog.md) (Phases 9 and 11). It's kept visible rather than hidden because "know when to cut scope" is as much a real engineering skill as building the thing in the first place.

---

# Documentation

| Document | Description |
|----------|-------------|
| `architecture.md` | Infrastructure architecture |
| `network.md` | Network topology and routing |
| `inventory.md` | Infrastructure inventory |
| `runbook.md` | Operational procedures |
| `health-checks.md` | Health verification guide |
| `troubleshooting.md` | Common issues and resolutions |
| `disaster-recovery.md` | Recovery procedures |
| `validation-report.md` | Infrastructure validation |
| `postmortems.md` | Dated incident log — what broke and how it was fixed |
| `project-timeline.md` | Project lifecycle |
| `changelog.md` | Infrastructure changes |

All documentation lives in [`docs/`](docs/). Diagrams live in [`architecture/`](architecture/).

---

# Infrastructure Validation

The environment has been validated across:

- Infrastructure
- Networking
- Kubernetes
- Monitoring
- Logging
- Disaster Recovery
- Infrastructure as Code

**Operational Status:** ✅ Fully Validated (last verified against live systems 2026-07-18)

**Open Items:** a handful of small, low-severity items — an orphaned Portainer Compose project and a couple of minor operational caveats — are tracked in [`docs/troubleshooting.md`](docs/troubleshooting.md).

---

# Screenshots

## Homepage

![Homepage](screenshots/homepage-dashboard.png)

## Grafana

![Grafana](screenshots/grafana-dashboard.png)

## Prometheus

![Prometheus](screenshots/prometheus-targets.png)

## Loki

![Loki](screenshots/loki-logs.png)

## Portainer

![Portainer](screenshots/portainer.png)

## Proxmox

![Proxmox](screenshots/proxmox-summary.png)

---

# Future Roadmap

- Write a real compose file for the orphaned `core-services`/Portainer project
- GitOps with Argo CD or Flux
- Automated Proxmox backup validation
- Persistent Volumes in Kubernetes
- Synthetic uptime monitoring (Uptime Kuma)
- Internal reverse proxy / friendly domains (Caddy or Traefik)
- ESP32 telemetry integration
- Advanced Grafana dashboards
- Tailscale ACLs
- Automated infrastructure testing
- CI/CD for documentation
- Expanded Kubernetes workloads
- GPU passthrough for the idle NVIDIA GTX 1660 Super (transcoding or local ML experimentation)

See [`HOMELAB_ROADMAP.md`](HOMELAB_ROADMAP.md) for the full roadmap with context and history.

---

# Repository Structure

```text
.
├── docs/
│   ├── architecture.md
│   ├── network.md
│   ├── inventory.md
│   ├── runbook.md
│   ├── health-checks.md
│   ├── troubleshooting.md
│   ├── disaster-recovery.md
│   ├── validation-report.md
│   ├── postmortems.md
│   ├── project-timeline.md
│   └── changelog.md
├── architecture/
│   ├── README.md
│   ├── architecture-diagram.mmd
│   ├── metrics-flow.mmd
│   ├── logging-flow.mmd
│   ├── alerting-flow.mmd
│   └── recovery-flow.mmd
├── screenshots/
├── docker-compose/
├── terraform/
├── HOMELAB_ROADMAP.md
└── README.md
```

---

# Goals

This project is built to gain practical experience with:

- Linux System Administration
- Virtualization
- Kubernetes
- Docker
- Infrastructure as Code
- Networking
- Site Reliability Engineering
- Observability
- Incident Response
- Disaster Recovery
- Production-style Documentation

---

# License

This project is licensed under the MIT License.
