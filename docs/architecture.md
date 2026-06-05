# Architecture

## Overview

The HomeLab environment is designed as a small-scale infrastructure platform for learning and practicing:

* Infrastructure Engineering
* DevOps
* Site Reliability Engineering (SRE)
* Linux Administration
* Observability
* Infrastructure as Code
* Incident Response
* Disaster Recovery

The architecture emphasizes:

* Private-by-default networking
* Remote administration
* Service isolation
* Centralized observability
* Repeatable infrastructure workflows

---

# Physical Infrastructure

## Apollo

Primary Infrastructure Host

Platform:

* Proxmox VE

Responsibilities:

* Hypervisor
* Virtual Machine Hosting
* LXC Hosting
* Virtual Networking
* Storage Management

---

## Artemis

Management Workstation

Platform:

* Arch Linux

Responsibilities:

* Infrastructure Administration
* SSH Management
* Git Operations
* Terraform Development
* Documentation
* Remote Access

---

# Virtual Infrastructure

## Athena

Ubuntu Virtual Machine

Purpose:

Monitoring, observability, administration, and infrastructure experimentation.

Services:

| Service          | Purpose                      |
| ---------------- | ---------------------------- |
| Grafana          | Dashboards and Visualization |
| Prometheus       | Metrics Collection           |
| Loki             | Log Aggregation              |
| Grafana Alloy    | Log Collection               |
| Node Exporter    | Host Metrics                 |
| Proxmox Exporter | Proxmox Metrics              |
| Portainer        | Container Management         |
| LocalStack       | AWS Service Emulation        |

---

## Hestia

Linux Container (LXC)

Purpose:

Self-hosted services platform.

Services:

| Service     | Purpose                  |
| ----------- | ------------------------ |
| Homepage    | Infrastructure Dashboard |
| Vaultwarden | Password Management      |

---

# High-Level Architecture

```text
Internet
    │
    ▼
Airtel Fiber Router
    │
    ▼
Apollo (Proxmox VE)
│
├── Athena (Ubuntu VM)
│   ├── Grafana
│   ├── Prometheus
│   ├── Loki
│   ├── Grafana Alloy
│   ├── Portainer
│   └── LocalStack
│
└── Hestia (LXC)
    ├── Homepage
    └── Vaultwarden
```

---

# Networking Architecture

The homelab operates as a private internal environment.

Design principles:

* No intentional public exposure
* Internal service communication
* Remote administration through Tailscale
* No router port forwarding

---

# Remote Access Architecture

```text
Artemis
    │
    ▼
Tailscale Network
    │
    ▼
Apollo
    │
    ├── Athena
    │
    └── Hestia
```

Benefits:

* Encrypted communication
* Device authentication
* Reduced attack surface
* Secure remote administration

---

# Metrics Architecture

Metrics are collected through exporters and stored in Prometheus.

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

Capabilities:

* Host Monitoring
* VM Monitoring
* Resource Utilization Tracking
* Capacity Planning
* Infrastructure Visibility

---

# Logging Architecture

Logs are collected using Grafana Alloy and stored in Loki.

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

Capabilities:

* Centralized Logging
* Historical Log Search
* Container Log Aggregation
* Troubleshooting Support

---

# Alerting Architecture

Alerting is implemented through Grafana Alerting with Telegram notifications.

```text
Prometheus
        │
        ▼
Grafana Alerting
        │
        ▼
Telegram
```

Alert Types:

* Host Availability
* Service Availability
* High CPU Utilization
* High Memory Utilization
* Disk Utilization
* Infrastructure Health

---

# Infrastructure as Code Architecture

Terraform is used with LocalStack for local cloud experimentation.

```text
Terraform
        │
        ▼
LocalStack
        │
        ├── S3
        └── DynamoDB
```

Current Resources:

* tf-homelab-storage-bucket
* tf-homelab-metadata

Benefits:

* Repeatable Deployments
* Safe Experimentation
* No Cloud Costs
* Local Testing Environment

---

# Service Placement Rationale

## Athena

Chosen for:

* Monitoring workloads
* Containerized services
* Observability stack
* Terraform experimentation

Benefits:

* Resource flexibility
* Easy backup and migration
* Isolation from Proxmox host

---

## Hestia

Chosen for:

* Lightweight service hosting
* Low resource requirements
* Simplified management

Benefits:

* Fast startup
* Reduced overhead
* Efficient resource utilization

---

# Security Design

Security principles include:

* Private-by-default networking
* No public-facing services
* Tailscale-only remote access
* Service isolation
* Internal communications only

Future improvements:

* Tailscale ACLs
* Device Tagging
* Access Segmentation

---

# Operational Status

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
| Metrics Pipeline  | Operational |
| Logging Pipeline  | Operational |
| Alerting Pipeline | Operational |

---

# Architecture Status

Current Phase:

Stable Operational Environment

The architecture currently supports infrastructure monitoring, centralized logging, alerting, remote administration, self-hosted services, and Infrastructure as Code experimentation while remaining fully manageable through secure remote access.
