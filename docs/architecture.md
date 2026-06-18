# Architecture

## Overview

The Olympus HomeLab is a production-inspired infrastructure platform designed to simulate real-world DevOps, Site Reliability Engineering (SRE), and cloud-native operational practices within a self-hosted environment.

The platform serves as a practical environment for developing skills in:

* Infrastructure Engineering
* DevOps
* Site Reliability Engineering (SRE)
* Linux Administration
* Observability
* Infrastructure as Code (IaC)
* Incident Response
* Disaster Recovery
* Systems Design

---

## Architectural Principles

The architecture is guided by the following principles:

* Private-by-default networking
* Service isolation
* Remote-first administration
* Centralized observability
* Reproducible infrastructure
* Lightweight workload placement
* Operational resilience
* Incremental evolution through experimentation

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
    │   ├── Olympus Dashboard API
    │   └── Floci
    │
    └── Hestia (Alpine LXC)
        ├── Homepage
        └── Vaultwarden
```

---

# Physical Infrastructure

## Apollo

**Primary Infrastructure Host**

Apollo serves as the compute foundation of the homelab.

### Platform

* Proxmox VE (Type-1 Hypervisor)

### Responsibilities

* Virtual Machine Hosting
* LXC Hosting
* Storage Management
* Virtual Networking
* Hardware Abstraction

### Design Rationale

Separating workloads from the hypervisor improves portability, backup flexibility, and operational safety.

---

## Artemis

**Management Workstation**

Artemis functions as the operational control point for the environment.

### Platform

* Arch Linux

### Responsibilities

* Infrastructure Administration
* SSH Management
* Git Operations
* Terraform Development
* Documentation
* Remote Access

### Design Rationale

Keeping management tooling external to the infrastructure ensures administrative access remains available during partial service failures.

---

# Virtualized Workload Segregation

To mirror production deployment patterns, workloads are separated into platform services and user-facing applications.

---

## Athena (Ubuntu VM)

### Role

Operations, Observability, and Local Development Platform.

### Hosted Services

| Service               | Purpose                      |
| --------------------- | ---------------------------- |
| Grafana               | Dashboards and Visualization |
| Prometheus            | Metrics Collection           |
| Loki                  | Log Aggregation              |
| Grafana Alloy         | Log Collection               |
| Node Exporter         | Host Metrics                 |
| Proxmox Exporter      | Proxmox Metrics              |
| Portainer             | Container Management         |
| Olympus Dashboard API | Homepage Data Services       |
| Floci                 | AWS Service Emulation        |

### Design Rationale

Athena was deployed as a full virtual machine because observability and development workloads require:

* Greater resource flexibility
* Broad software compatibility
* Independent lifecycle management
* Isolation from the hypervisor

---

## Hestia (CT 101)

### Role

Self-Hosted Application Platform.

### Hosted Services

| Service     | Purpose                  |
| ----------- | ------------------------ |
| Homepage    | Infrastructure Dashboard |
| Vaultwarden | Password Management      |

### Design Rationale

Hestia uses an unprivileged Alpine Linux LXC to provide:

* Minimal overhead
* Rapid startup times
* Efficient resource utilization
* Strong workload isolation

This placement is well suited to lightweight, continuously running services.

---

# Observability Architecture

The observability stack provides unified visibility across the environment.

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

### Capabilities

* Host Monitoring
* VM Monitoring
* Capacity Planning
* Resource Utilization Tracking
* Infrastructure Visibility

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

### Capabilities

* Centralized Logging
* Historical Log Search
* Container Log Aggregation
* Troubleshooting Support

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

### Alert Coverage

* Host Availability
* Service Availability
* CPU Utilization
* Memory Utilization
* Disk Capacity
* Infrastructure Health

---

# Infrastructure as Code Architecture

Infrastructure provisioning and experimentation are managed through Terraform.

## Active Cloud Emulation

```text
Terraform
        │
        ▼
Floci
        │
        ├── S3
        └── DynamoDB
```

### Managed Resources

* `tf-homelab-storage-bucket`
* `tf-homelab-metadata`

### Benefits

* Reproducible Deployments
* Safe Experimentation
* Zero Cloud Cost
* Local Validation of AWS Workflows

---

## Architectural Evolution

Floci replaced LocalStack as the active AWS emulation platform due to its significantly lower startup time and resource consumption.

LocalStack is retained as a historical reference and compatibility artifact documenting the platform's evolution.

---

# Dashboard Data Architecture

Custom Homepage widgets rely on a decoupled synchronization pipeline.

```text
Hestia
    │
    ├── Collect External Data
    │
    ▼
Generate JSON Assets
    │
    ▼
Secure SCP Synchronization
    │
    ▼
Athena
    │
    ▼
Olympus Dashboard API
    │
    ▼
Homepage Widgets
```

### Design Goals

* Decouple data collection from presentation
* Minimize external dependencies in the frontend
* Preserve dashboard responsiveness
* Support extensible widget development

---

# Security Architecture

The homelab follows a defense-in-depth approach.

## Security Principles

* Private-by-default networking
* No intentional public exposure
* Tailscale-only remote administration
* Service isolation
* Internal service communication
* Least-exposure design

---

## Remote Access Model

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
    └── Hestia (Indirect Access)
```

### Security Decisions

* No public SSH access
* No router port forwarding
* Device-authenticated administration
* Encrypted WireGuard transport
* Hestia excluded from the Tailscale mesh to reduce exposure of sensitive services

---

# Operational Status

| Component         | Status      |
| ----------------- | ----------- |
| Apollo            | Healthy     |
| Artemis           | Healthy     |
| Athena            | Healthy     |
| Hestia            | Healthy     |
| Grafana           | Healthy     |
| Prometheus        | Healthy     |
| Loki              | Healthy     |
| Grafana Alloy     | Healthy     |
| Node Exporter     | Healthy     |
| Proxmox Exporter  | Healthy     |
| Floci             | Healthy     |
| Metrics Pipeline  | Operational |
| Logging Pipeline  | Operational |
| Alerting Pipeline | Operational |

---

# Current Architecture State

**Phase:** Stable Operational Environment

The Olympus HomeLab currently provides:

* Centralized observability
* Secure remote administration
* Self-hosted application services
* Local AWS workflow experimentation
* Automated dashboard integrations
* Infrastructure as Code validation
* Operational resilience through documented processes

The architecture continues to evolve incrementally through experimentation while preserving production-inspired design principles.
