# Infrastructure Inventory

## Overview

This document provides a complete inventory of physical systems, virtual infrastructure, services, observability components, networking, and Infrastructure as Code resources currently deployed in the HomeLab environment.

---

## Physical Systems

### Apollo

**Primary Infrastructure Host**

- **Platform:** Proxmox VE
- **Role:** Hypervisor
- **Responsibilities:**
  - VM Hosting
  - LXC Hosting
  - Storage Management
  - Virtual Networking
  - Infrastructure Core Services
- **Status:** Healthy

### Artemis

**Management Workstation**

- **Platform:** Arch Linux
- **Role:** Administration Workstation
- **Responsibilities:**
  - SSH Administration
  - Git Operations
  - Terraform Development
  - Documentation
  - Remote Infrastructure Management
- **Status:** Healthy

---

## Virtual Infrastructure

### Athena

- **Type:** Ubuntu Virtual Machine
- **Purpose:** Operations, Monitoring, Observability, and Infrastructure Testing
- **Status:** Healthy

#### Hosted Services

| Service | Function |
|----------|----------|
| Grafana | Visualization and Dashboards |
| Prometheus | Metrics Collection |
| Loki | Log Aggregation |
| Grafana Alloy | Log Collection |
| Node Exporter | Host Metrics |
| Proxmox Exporter | Proxmox Metrics |
| Portainer | Container Management |
| LocalStack | AWS Service Emulation |

### Hestia

- **Type:** Linux Container (LXC)
- **Purpose:** Self-Hosted Applications
- **Status:** Healthy

#### Hosted Services

| Service | Function |
|----------|----------|
| Homepage | Service Dashboard |
| Vaultwarden | Password Manager |

---

## Docker Services

### Telemetry Stack

- **Host:** Athena
- **Status:** Operational

| Service | Purpose |
|----------|----------|
| Grafana | Visualization |
| Prometheus | Metrics Storage |
| Loki | Log Storage |
| Grafana Alloy | Log Collection |
| Node Exporter | Host Metrics |
| Proxmox Exporter | Proxmox Metrics |

### LocalStack Stack

- **Host:** Athena
- **Status:** Operational

| Service | Purpose |
|----------|----------|
| LocalStack | AWS Emulation |

### Core Services Stack

- **Host:** Hestia
- **Status:** Operational

| Service | Purpose |
|----------|----------|
| Homepage | Service Dashboard |
| Vaultwarden | Password Management |

---

## Monitoring Inventory

### Prometheus

- **Function:** Metrics Collection and Storage
- **Monitored Targets:** Node Exporter, Proxmox Exporter
- **Status:** Healthy

### Grafana

- **Function:** Visualization and Alerting
- **Features:** Dashboards, Alerting, Log Exploration, Metrics Visualization
- **Status:** Healthy

### Node Exporter

- **Function:** Host Metrics Collection
- **Metrics:** CPU, Memory, Disk, Network
- **Status:** Healthy

### Proxmox Exporter

- **Function:** Proxmox Metrics Collection
- **Metrics:** Node Metrics, VM Metrics, Storage Metrics
- **Status:** Healthy

---

## Logging Inventory

### Loki

- **Function:** Centralized Log Storage
- **Features:** Log Aggregation, Querying, Historical Retention
- **Status:** Healthy

### Grafana Alloy

- **Function:** Telemetry Collection
- **Responsibilities:**
  - Docker Log Discovery
  - Log Collection
  - Log Forwarding
- **Destination:** Loki
- **Status:** Healthy

---

## Alerting Inventory

### Grafana Alerting

- **Function:** Alert Evaluation and Notification
- **Alert Delivery:** Telegram
- **Purpose:**
  - Infrastructure Alerts
  - Service Health Alerts
  - Resource Utilization Alerts
- **Status:** Operational

### Telegram Notifications

- **Purpose:** Incident Notification
- **Status:** Operational

---

## Infrastructure as Code Inventory

### Terraform

- **Purpose:** Infrastructure Automation
- **Environment:** LocalStack
- **Status:** Operational

### LocalStack

- **Purpose:** AWS Service Emulation
- **Services Used:**
  - S3
  - DynamoDB
- **Status:** Operational

### Managed Resources

- **S3 Bucket:** `tf-homelab-storage-bucket`
- **DynamoDB Table:** `tf-homelab-metadata`

---

## Networking Inventory

### Router

- **Provider:** Airtel Fiber
- **Status:** Operational

### Tailscale

- **Purpose:** Remote Administration
- **Connected Nodes:**
  - Artemis
  - Apollo
  - Athena
- **Status:** Operational

### Proxmox Bridge

- **Purpose:**
  - VM Connectivity
  - LXC Connectivity
  - External Network Access
- **Status:** Operational

---

## Documentation Inventory

| Document | Purpose |
|----------|----------|
| `architecture.md` | Architecture Overview |
| `network.md` | Network Design |
| `inventory.md` | Infrastructure Inventory |
| `runbook.md` | Operational Procedures |
| `troubleshooting.md` | Incident Documentation |
| `disaster-recovery.md` | Recovery Procedures |
| `validation-report.md` | Validation Results |
| `changelog.md` | Change Tracking |
| `project-timeline.md` | Project History |
| `health-checks.md` | Health Verification |

---

## Operational Status Summary

| Component | Status |
|----------|----------|
| Apollo | Healthy |
| Athena | Healthy |
| Hestia | Healthy |
| Grafana | Healthy |
| Prometheus | Healthy |
| Loki | Healthy |
| Grafana Alloy | Healthy |
| Node Exporter | Healthy |
| Proxmox Exporter | Healthy |
| LocalStack | Healthy |
| Tailscale | Operational |
| Metrics Pipeline | Operational |
| Logging Pipeline | Operational |
| Alerting Pipeline | Operational |

---

## Summary

The HomeLab environment consists of:

- **1 Physical Hypervisor:** Apollo
- **1 Management Workstation:** Artemis
- **1 Ubuntu VM:** Athena
- **1 LXC Container:** Hestia
- **8 Monitoring & Infrastructure Services**
- **2 Core Self-Hosted Services**
- **Terraform-managed LocalStack Resources**
- **Tailscale-based Remote Administration**
- **Centralized Metrics, Logging, and Alerting**

**Overall Infrastructure Status:** Healthy and Operational