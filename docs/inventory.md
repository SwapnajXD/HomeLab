# Infrastructure Inventory

## Overview

This document provides a complete inventory of physical systems, virtual infrastructure, containerized services, observability components, networking, automation workflows, and Infrastructure as Code resources currently deployed in the Olympus HomeLab environment.

---

## Environment Summary

| Category                 | Count |
| ------------------------ | ----- |
| Physical Systems         | 2     |
| Hypervisors              | 1     |
| Virtual Machines         | 1     |
| LXC Containers           | 1     |
| Docker Services          | 10    |
| Monitoring Components    | 6     |
| Self-Hosted Applications | 2     |
| Automation Pipelines     | 1     |

---

## Infrastructure Topology

```text
Artemis (Management Workstation)
└── Apollo (Proxmox VE)
    ├── VM 100: Athena
    └── CT 101: Hestia
```

---

## Physical Systems

### Apollo

**Primary Infrastructure Host**

* Platform: Proxmox VE
* Role: Hypervisor
* Status: Healthy

#### Responsibilities

* VM Hosting
* LXC Hosting
* Storage Management
* Virtual Networking
* Infrastructure Core Services

#### Hosted Workloads

* VM 100: Athena
* CT 101: Hestia

---

### Artemis

**Management Workstation**

* Platform: Arch Linux
* Type: Physical Laptop
* Role: Administration Workstation
* Status: Healthy

#### Responsibilities

* SSH Administration
* Git Operations
* Terraform Development
* Documentation
* Remote Infrastructure Management

---

## Virtual Infrastructure

### Athena (VM 100)

**Operations, Monitoring, and Infrastructure Services**

* Type: Ubuntu Server Virtual Machine
* Runtime: Docker Compose
* LAN IP: `10.10.10.10`
* Tailscale IP: `100.117.35.70`
* Status: Healthy

#### Hosted Services

| Service               | Port        | Purpose                 |
| --------------------- | ----------- | ----------------------- |
| Grafana               | `3001:3000` | Dashboards and Alerting |
| Prometheus            | `9090:9090` | Metrics Collection      |
| Loki                  | `3100:3100` | Log Aggregation         |
| Grafana Alloy         | Host Mode   | Telemetry Collection    |
| Node Exporter         | Internal    | Host Metrics            |
| Proxmox Exporter      | Internal    | Proxmox Metrics         |
| Portainer CE          | `9443:9443` | Container Management    |
| Olympus Dashboard API | `8000:8000` | Homepage Data API       |
| Floci                 | `4566:4566` | AWS Emulation           |
| LocalStack            | Archived    | Legacy Reference        |

---

### Hestia (CT 101)

**Self-Hosted Application Container**

* Type: Unprivileged Alpine Linux LXC
* LAN IP: `10.10.10.2`
* Tailscale: Not Enabled
* Status: Healthy

> Hestia is intentionally isolated from the Tailscale network to reduce exposure of sensitive applications.

#### Hosted Services

| Service     | Port   | Data Path           | Purpose             |
| ----------- | ------ | ------------------- | ------------------- |
| Homepage    | `3000` | `homepage-config/`  | Service Dashboard   |
| Vaultwarden | `8080` | `vaultwarden-data/` | Password Management |

---

## Monitoring Inventory

### Prometheus

* Function: Metrics Collection and Storage
* Monitored Targets:

  * Node Exporter
  * Proxmox Exporter
* Status: Healthy

---

### Grafana

* Function: Visualization and Alerting
* Features:

  * Dashboards
  * Alerting
  * Metrics Exploration
  * Log Exploration
* Status: Healthy

---

### Node Exporter

* Function: Host Metrics Collection
* Metrics:

  * CPU
  * Memory
  * Disk
  * Network
* Status: Healthy

---

### Proxmox Exporter

* Function: Proxmox Metrics Collection
* Metrics:

  * Node Metrics
  * VM Metrics
  * Storage Metrics
* Status: Healthy

---

## Logging Inventory

### Loki

* Function: Centralized Log Storage
* Features:

  * Log Aggregation
  * Querying
  * Historical Retention
* Status: Healthy

---

### Grafana Alloy

* Function: Telemetry Collection

#### Responsibilities

* Docker Log Discovery
* Log Collection
* Log Forwarding

#### Destination

* Loki

* Status: Healthy

---

## Alerting Inventory

### Grafana Alerting

* Function: Alert Evaluation and Notification
* Notification Channel: Telegram
* Status: Operational

#### Alert Categories

* Infrastructure Alerts
* Service Health Alerts
* Resource Utilization Alerts

---

### Telegram Notifications

* Purpose: Incident Notification
* Status: Operational

---

## Automation Pipelines

### Homepage Data Pipeline

Personalized data is collected on Hestia and synchronized to Athena for use by the Olympus Dashboard API.

#### Data Sources

| Asset          | Source         |
| -------------- | -------------- |
| `weather.json` | wttr.in        |
| `pokemon.json` | PokeAPI        |
| `lastfm.json`  | Last.fm        |
| `prices.json`  | Financial APIs |

#### Configuration

* Source Directory:
  `~/homelab/personal-services/homepage-config/data/`
* Execution Method:
  Cron Jobs
* Frequency:
  Every 5 Minutes
* Transport:
  SSH using Ed25519 Keys
* Destination:
  Athena Dashboard API Data Store

---

## Infrastructure as Code Inventory

### Terraform

* Purpose: Infrastructure Automation
* Status: Operational

#### Provider Endpoint

`http://10.10.10.10:4566`

---

### Floci

**Active AWS Emulation Environment**

* Purpose: AWS Service Emulation
* Status: Operational

#### Services Used

* S3
* DynamoDB

---

### Legacy LocalStack

* Status: Archived
* Purpose: Historical Reference
* Image:
  `localstack/localstack:4.4.0`

---

### Managed Resources

| Resource                    | Purpose                 |
| --------------------------- | ----------------------- |
| `tf-homelab-storage-bucket` | S3 Validation Storage   |
| `tf-homelab-metadata`       | DynamoDB Metadata Store |

---

## Networking Inventory

### Router

* Provider: Airtel Fiber
* Status: Operational

---

### Tailscale

* Purpose: Remote Administration
* Status: Operational

#### Connected Nodes

* Artemis
* Apollo
* Athena

---

### Proxmox Bridge

* Bridge: `vmbr0`
* Purpose:

  * VM Connectivity
  * LXC Connectivity
  * External Network Access
* Status: Operational

---

## Architecture Decisions

### Why Athena Hosts Observability

Separating observability workloads from the Proxmox host provides visibility during partial infrastructure failures.

---

### Why Hestia Does Not Use Tailscale

Sensitive applications remain accessible only through trusted internal paths, reducing unnecessary exposure.

---

### Why Floci Replaced LocalStack

Floci provides the active AWS emulation environment, while LocalStack is retained only for compatibility and historical reference.

---

## Documentation Inventory

| Document               | Purpose                  |
| ---------------------- | ------------------------ |
| `architecture.md`      | Architecture Overview    |
| `network.md`           | Network Design           |
| `inventory.md`         | Infrastructure Inventory |
| `runbook.md`           | Operational Procedures   |
| `troubleshooting.md`   | Incident Documentation   |
| `disaster-recovery.md` | Recovery Procedures      |
| `validation-report.md` | Validation Results       |
| `changelog.md`         | Change Tracking          |
| `project-timeline.md`  | Project History          |
| `health-checks.md`     | Health Verification      |

---

## Operational Status Summary

| Component           | Status      |
| ------------------- | ----------- |
| Apollo              | Healthy     |
| Artemis             | Healthy     |
| Athena              | Healthy     |
| Hestia              | Healthy     |
| Grafana             | Healthy     |
| Prometheus          | Healthy     |
| Loki                | Healthy     |
| Grafana Alloy       | Healthy     |
| Node Exporter       | Healthy     |
| Proxmox Exporter    | Healthy     |
| Floci               | Operational |
| Tailscale           | Operational |
| Metrics Pipeline    | Operational |
| Logging Pipeline    | Operational |
| Alerting Pipeline   | Operational |
| Automation Pipeline | Operational |

---

## Summary

The Olympus HomeLab environment consists of:

* 1 Physical Hypervisor (Apollo)
* 1 Management Workstation (Artemis)
* 1 Ubuntu Server VM (Athena)
* 1 Alpine Linux LXC (Hestia)
* 10 Containerized Services
* Centralized Metrics, Logging, and Alerting
* Terraform-managed AWS Emulation Resources
* Automated Homepage Data Synchronization
* Tailscale-based Remote Administration

**Overall Infrastructure Status: Healthy and Operational**
