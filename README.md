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
             Tailscale Mesh
                    │
                Apollo
          Proxmox VE Hypervisor
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
 Prometheus                 Homepage (stock)
 Loki                       Vaultwarden
 Grafana Alloy
 Portainer
 Floci
```

Full Mermaid diagrams (rendered natively on GitHub): [`architecture/architecture-diagram.mmd`](architecture/architecture-diagram.mmd) and the rest of the [`architecture/`](architecture/) directory.

---

# Infrastructure Overview

## Apollo

**Role:** Proxmox VE Hypervisor

Responsibilities:

- Virtualization
- Storage Management
- Virtual Networking
- Persistent NAT Gateway
- Port Forwarding

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
- Portainer
- Floci
- K3s Kubernetes Cluster

---

## Hestia (CT 101)

**Role:** Frontend Platform

Hosted Services:

- Homepage — stock configuration, service links only
- Vaultwarden

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

Both the widget and its backend API have been fully removed. Homepage now runs in its stock configuration. The full build-it, learn-from-it, remove-it story — including every incident and fix along the way — is documented in [`docs/postmortems.md`](docs/postmortems.md) and [`docs/changelog.md`](docs/changelog.md) (Phases 9 and 11). It's kept visible rather than deleted from history because "know when to cut scope" is as much a real engineering skill as building the thing in the first place.

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

**Operational Status:** ✅ Fully Validated

**Known Open Issue:** Grafana Alloy is currently only discovering logs for 2 of 9 running containers on Athena — tracked in [`docs/troubleshooting.md`](docs/troubleshooting.md).

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

- Fix Grafana Alloy's Docker log discovery gap
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
