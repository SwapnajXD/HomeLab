# Infrastructure Inventory

## Overview

This document provides a complete inventory of physical systems, virtual infrastructure, services, observability components, networking, and Infrastructure as Code resources currently deployed in the HomeLab environment.

---

# Physical Systems

## Apollo

Primary Infrastructure Host

### Platform

* Proxmox VE

### Role

Hypervisor

### Responsibilities

* VM Hosting
* LXC Hosting
* Storage Management
* Virtual Networking
* Infrastructure Core Services

### Status

Healthy

---

## Artemis

Management Workstation

### Platform

* Arch Linux

### Role

Administration Workstation

### Responsibilities

* SSH Administration
* Git Operations
* Terraform Development
* Documentation
* Remote Infrastructure Management

### Status

Healthy

---

# Virtual Infrastructure

## Athena

### Type

Ubuntu Virtual Machine

### Purpose

Operations, Monitoring, Observability, and Infrastructure Testing

### Status

Healthy

### Hosted Services

| Service          | Function                     |
| ---------------- | ---------------------------- |
| Grafana          | Visualization and Dashboards |
| Prometheus       | Metrics Collection           |
| Loki             | Log Aggregation              |
| Grafana Alloy    | Log Collection               |
| Node Exporter    | Host Metrics                 |
| Proxmox Exporter | Proxmox Metrics              |
| Portainer        | Container Management         |
| LocalStack       | AWS Service Emulation        |

---

## Hestia

### Type

Linux Container (LXC)

### Purpose

Self-Hosted Applications

### Status

Healthy

### Hosted Services

| Service     | Function          |
| ----------- | ----------------- |
| Homepage    | Service Dashboard |
| Vaultwarden | Password Manager  |

---

# Docker Services

## Telemetry Stack

Host:

Athena

### Components

| Service          | Purpose         |
| ---------------- | --------------- |
| Grafana          | Visualization   |
| Prometheus       | Metrics Storage |
| Loki             | Log Storage     |
| Grafana Alloy    | Log Collection  |
| Node Exporter    | Host Metrics    |
| Proxmox Exporter | Proxmox Metrics |

Status:

Operational

---

## LocalStack Stack

Host:

Athena

### Components

| Service    | Purpose       |
| ---------- | ------------- |
| LocalStack | AWS Emulation |

Status:

Operational

---

## Core Services Stack

Host:

Hestia

### Components

| Service     | Purpose             |
| ----------- | ------------------- |
| Homepage    | Service Dashboard   |
| Vaultwarden | Password Management |

Status:

Operational

---

# Monitoring Inventory

## Prometheus

### Function

Metrics Collection and Storage

### Monitored Targets

* Node Exporter
* Proxmox Exporter

### Status

Healthy

---

## Grafana

### Function

Visualization and Alerting

### Features

* Dashboards
* Alerting
* Log Exploration
* Metrics Visualization

### Status

Healthy

---

## Node Exporter

### Function

Host Metrics Collection

### Metrics

* CPU
* Memory
* Disk
* Network

### Status

Healthy

---

## Proxmox Exporter

### Function

Proxmox Metrics Collection

### Metrics

* Node Metrics
* VM Metrics
* Storage Metrics

### Status

Healthy

---

# Logging Inventory

## Loki

### Function

Centralized Log Storage

### Features

* Log Aggregation
* Querying
* Historical Retention

### Status

Healthy

---

## Grafana Alloy

### Function

Telemetry Collection

### Responsibilities

* Docker Log Discovery
* Log Collection
* Log Forwarding

### Destination

* Loki

### Status

Healthy

---

# Alerting Inventory

## Grafana Alerting

### Function

Alert Evaluation and Notification

### Alert Delivery

Telegram

### Current Status

Operational

### Purpose

* Infrastructure Alerts
* Service Health Alerts
* Resource Utilization Alerts

---

## Telegram Notifications

### Purpose

Incident Notification

### Delivery Path

```text
Prometheus
        │
        ▼
Grafana Alerting
        │
        ▼
Telegram
```

### Status

Operational

---

# Infrastructure as Code Inventory

## Terraform

### Purpose

Infrastructure Automation

### Status

Operational

### Environment

LocalStack

---

## LocalStack

### Purpose

AWS Service Emulation

### Status

Operational

### Services Used

* S3
* DynamoDB

---

## Managed Resources

### S3 Bucket

```text
tf-homelab-storage-bucket
```

---

### DynamoDB Table

```text
tf-homelab-metadata
```

---

# Networking Inventory

## Router

Provider:

Airtel Fiber

### Status

Operational

---

## Tailscale

### Purpose

Remote Administration

### Connected Nodes

* Artemis
* Apollo
* Athena

### Status

Operational

---

## Proxmox Bridge

### Bridge

```text
vmbr0
```

### Purpose

* VM Connectivity
* LXC Connectivity
* External Network Access

### Status

Operational

---

# Documentation Inventory

Current documentation includes:

| Document             | Purpose                  |
| -------------------- | ------------------------ |
| architecture.md      | Architecture Overview    |
| network.md           | Network Design           |
| inventory.md         | Infrastructure Inventory |
| runbook.md           | Operational Procedures   |
| troubleshooting.md   | Incident Documentation   |
| disaster-recovery.md | Recovery Procedures      |
| validation-report.md | Validation Results       |
| changelog.md         | Change Tracking          |
| project-timeline.md  | Project History          |
| health-checks.md     | Health Verification      |

---

# Operational Status Summary

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

# Inventory Status

Last Reviewed:

Current Infrastructure State

Overall Status:

```text
Fully Operational
```
