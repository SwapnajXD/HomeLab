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

The environment is designed around a layered architecture where infrastructure, operations, and frontend services are separated into dedicated nodes. It is fully manageable through **Tailscale** and documented with production-style operational procedures.

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
      │                           │
 Docker + K3s                Docker Compose
      │                           │
 Grafana                    Homepage
 Prometheus                 Vaultwarden
 Loki
 Grafana Alloy
 Dashboard API
 Portainer
 Floci
```

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

**Role:** Operations Platform

Hosted Services:

- Grafana
- Prometheus
- Loki
- Grafana Alloy
- Node Exporter
- Proxmox Exporter
- Olympus Dashboard API
- Portainer
- Floci
- K3s Kubernetes Cluster

---

## Hestia (CT 101)

**Role:** Frontend Platform

Hosted Services:

- Homepage Dashboard
- Vaultwarden

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
- Single-node K3s Kubernetes cluster
- Secure remote administration with Tailscale
- Centralized metrics using Prometheus
- Centralized logging using Loki & Grafana Alloy
- Grafana dashboards and alerting
- Telegram alert notifications
- Infrastructure as Code with Terraform
- Local AWS emulation using Floci
- Custom FastAPI Dashboard Backend
- Automated dashboard data pipelines
- Disaster Recovery Runbook
- Operational Runbook
- Infrastructure Validation Reports
- Health Verification Procedures
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

## Dashboard

- FastAPI
- Homepage

---

# Dashboard V2

The dashboard follows a backend-first architecture.

```
External APIs
       │
       ▼
Fetch Scripts
       │
       ▼
flock Lock Protection
       │
       ▼
JSON Generation (jq)
       │
       ▼
Olympus Dashboard API
       │
       ▼
Homepage
```

Athena serves as the single source of truth for all dashboard data, while Hestia acts as a lightweight frontend.

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
| `project-timeline.md` | Project lifecycle |
| `changelog.md` | Infrastructure changes |

---

# Infrastructure Validation

The environment has been validated across:

- Infrastructure
- Networking
- Kubernetes
- Monitoring
- Logging
- Automation
- Disaster Recovery
- Infrastructure as Code

**Operational Status:** ✅ Fully Validated

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

- GitOps with Argo CD or Flux
- Automated Proxmox backup validation
- Traefik Ingress for K3s
- Persistent Volumes in Kubernetes
- ESP32 telemetry integration
- Advanced Grafana dashboards
- Tailscale ACLs
- Automated infrastructure testing
- CI/CD for documentation
- Expanded Kubernetes workloads

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
│   ├── project-timeline.md
│   └── changelog.md
├── screenshots/
├── docker-compose/
├── terraform/
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