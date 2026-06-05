# HomeLab

![Platform](https://img.shields.io/badge/platform-Proxmox-blue)
![OS](https://img.shields.io/badge/os-Ubuntu-orange)
![Containers](https://img.shields.io/badge/containers-Docker-blue)
![IaC](https://img.shields.io/badge/IaC-Terraform-purple)
![Monitoring](https://img.shields.io/badge/monitoring-Grafana%20%7C%20Prometheus-green)
![Logging](https://img.shields.io/badge/logging-Loki-yellow)
![Alerting](https://img.shields.io/badge/alerting-Telegram-success)
![VPN](https://img.shields.io/badge/network-Tailscale-blue)

A self-hosted homelab built on Proxmox VE for learning infrastructure engineering, observability, networking, automation, Infrastructure as Code, and disaster recovery practices.

The environment is fully manageable remotely through Tailscale and is designed to remain operational without physical access.

---

# Infrastructure Overview

```text
Artemis (Management Workstation)
        │
        ▼
    Tailscale
        │
        ▼
Apollo (Proxmox VE Host)
├── Hestia (LXC)
│   ├── Homepage Dashboard
│   └── Vaultwarden
│
└── Athena (Ubuntu VM)
    ├── Grafana
    ├── Prometheus
    ├── Loki
    ├── Grafana Alloy
    ├── Portainer
    └── LocalStack
```

---

# Key Achievements

* Built a multi-node Proxmox homelab
* Implemented secure remote management through Tailscale
* Centralized monitoring using Prometheus and Grafana
* Centralized log aggregation using Loki and Grafana Alloy
* Implemented Telegram-based infrastructure alerting
* Automated cloud resource provisioning using Terraform
* Validated infrastructure through reboot and disaster recovery testing
* Maintained complete infrastructure documentation
* Implemented Infrastructure as Code workflows using LocalStack and Terraform
* Performed troubleshooting and root cause analysis on production-style incidents

---

# Technology Stack

## Infrastructure

* Proxmox VE
* Ubuntu Server
* Linux Containers (LXC)
* Docker
* Docker Compose

## Networking

* Tailscale
* Linux Bridges
* Proxmox Virtual Networking

## Monitoring, Logging & Alerting

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Node Exporter
* Proxmox Exporter
* Telegram Alerting

## Automation & IaC

* Terraform
* LocalStack
* AWS CLI
* Bash

---

# Observability Platform

## Metrics Pipeline

```text
Node Exporter
        │
        ▼
Prometheus
        │
        ▼
Grafana

Proxmox Exporter
        │
        ▼
Prometheus
```

---

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
Grafana
```

---

## Alerting Pipeline

```text
Prometheus
        │
        ▼
Grafana Alerting
        │
        ▼
Telegram
```

---

# Infrastructure as Code

Terraform is used with LocalStack to simulate AWS services locally.

Current resources include:

* tf-homelab-storage-bucket
* tf-homelab-metadata

Benefits:

* Repeatable deployments
* Safe experimentation
* No cloud costs
* Infrastructure testing workflows

---

# Repository Structure

```text
HomeLab/
├── architecture/
├── configs/
│   ├── apollo/
│   ├── athena/
│   └── hestia/
├── docker-compose/
├── docs/
├── screenshots/
├── scripts/
├── terraform/
├── README.md
├── LICENSE
├── HOMELAB_ROADMAP.md
└── tree.txt
```

---

# Documentation

| Document                  | Description                        |
| ------------------------- | ---------------------------------- |
| docs/architecture.md      | Infrastructure architecture        |
| docs/network.md           | Network topology and routing       |
| docs/inventory.md         | Infrastructure inventory           |
| docs/runbook.md           | Operational procedures             |
| docs/troubleshooting.md   | Issues encountered and resolutions |
| docs/disaster-recovery.md | Recovery procedures                |
| docs/validation-report.md | Validation and testing results     |
| docs/changelog.md         | Infrastructure changes over time   |

---

# Screenshots

## Homepage Dashboard

![Homepage](screenshots/homepage-dashboard.png)

## Grafana Dashboard

![Grafana](screenshots/grafana-dashboard.png)

## Prometheus Targets

![Prometheus](screenshots/prometheus-targets.png)

## Loki Logs

![Loki](screenshots/loki-logs.png)

## Portainer

![Portainer](screenshots/portainer.png)

## Proxmox Summary

![Proxmox](screenshots/proxmox-summary.png)

---

# Current Status

| Component         | Status      |
| ----------------- | ----------- |
| Apollo            | Healthy     |
| Athena            | Healthy     |
| Hestia            | Healthy     |
| Grafana           | Healthy     |
| Prometheus        | Healthy     |
| Loki              | Healthy     |
| Grafana Alloy     | Healthy     |
| Node Exporter     | Healthy     |
| Proxmox Exporter  | Healthy     |
| LocalStack        | Healthy     |
| Tailscale         | Operational |
| Metrics Pipeline  | Operational |
| Logging Pipeline  | Operational |
| Alerting Pipeline | Operational |

---

# Major Incidents Investigated

## Proxmox Network Isolation Incident

### Root Cause

Incomplete bridge configuration resulted in VM and container connectivity issues.

### Resolution

Rebuilt and validated the Proxmox bridge configuration.

---

## Loki Readiness Incident

### Discovery

Incorrect readiness endpoint:

```text
/loki/api/v1/status/ready
```

Correct endpoint:

```text
/ready
```

### Resolution

Updated validation and monitoring procedures to use the correct endpoint.

---

# Project Goals

* Learn infrastructure engineering fundamentals
* Learn observability and monitoring practices
* Learn Infrastructure as Code workflows
* Practice disaster recovery procedures
* Build operational experience with self-hosted services
* Develop troubleshooting and incident response skills

---

# Roadmap

See:

```text
HOMELAB_ROADMAP.md
```

for the complete project roadmap and milestones.

---

# Skills Demonstrated

* Linux Administration
* Docker & Docker Compose
* Proxmox Virtualization
* Networking
* Tailscale
* Monitoring & Alerting
* Centralized Logging
* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Terraform
* LocalStack
* Infrastructure as Code
* Troubleshooting
* Root Cause Analysis
* Incident Response
* Disaster Recovery
* Documentation

---

# License

MIT License
