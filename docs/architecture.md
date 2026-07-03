# Architecture

## Overview

Olympus HomeLab is a production-inspired infrastructure platform built to simulate real-world DevOps, Site Reliability Engineering (SRE), and cloud-native operations within a self-hosted environment.

It serves as a practical environment for learning and validating:

- Infrastructure Engineering
- DevOps & SRE
- Linux Administration
- Infrastructure as Code (Terraform)
- Kubernetes
- Observability
- Incident Response
- Disaster Recovery
- Systems Design

---

# Architecture Principles

The platform is designed around several core principles:

- **Private-by-default networking** with controlled ingress
- **Service isolation** between platform and application workloads
- **Remote-first administration** using Tailscale and SSH
- **Centralized observability**
- **Infrastructure as Code**
- **Operational resilience**
- **Incremental evolution through experimentation**

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
    │   ├── K3s
    │   ├── Olympus Dashboard API
    │   ├── Portainer
    │   └── Floci
    │
    └── Hestia (Alpine LXC)
        ├── Homepage
        └── Vaultwarden
```

---

# Infrastructure

## Apollo

**Role:** Hypervisor & Network Gateway

Apollo is the bare-metal Proxmox VE host that provides the compute foundation for the homelab.

### Responsibilities

- Virtual machine and LXC hosting
- Storage management
- Virtual networking
- Hardware abstraction
- Persistent NAT gateway
- Port forwarding for internal services

Apollo uses `iptables` to provide outbound internet access for internal workloads and selectively forwards traffic to trusted internal services.

---

## Athena (Ubuntu VM)

**Role:** Operations, Observability & Kubernetes Platform

Athena acts as the operational core of the homelab.

### Hosted Services

| Service | Purpose |
|----------|---------|
| Grafana | Dashboards & Visualization |
| Prometheus | Metrics Collection |
| Loki | Centralized Logging |
| Grafana Alloy | Log Collection |
| Node Exporter | Host Metrics |
| Proxmox Exporter | Hypervisor Metrics |
| Portainer | Container Management |
| K3s | Kubernetes Lab |
| Olympus Dashboard API | Dashboard Backend |
| Floci | AWS Service Emulation |

### Responsibilities

- Centralized observability
- Kubernetes experimentation
- Dashboard data aggregation
- Container management
- Infrastructure monitoring

The K3s cluster operates as a single-node Kubernetes environment with cgroup v2 enabled for stable operation.

---

## Hestia (Alpine LXC)

**Role:** Application Frontend

Hestia hosts lightweight user-facing services.

### Hosted Services

| Service | Purpose |
|----------|---------|
| Homepage | Infrastructure Dashboard |
| Vaultwarden | Password Manager |

The container is intentionally lightweight, providing:

- Fast startup
- Low resource usage
- Strong workload isolation

Following the Dashboard V2 redesign, Hestia no longer performs backend data collection and instead consumes the centralized Dashboard API hosted on Athena.

---

## Artemis

**Role:** Management Workstation

Artemis is the external administration workstation used to manage the entire environment.

### Responsibilities

- SSH administration
- Git operations
- Terraform development
- Kubernetes management
- Documentation
- Remote infrastructure access

Keeping management tooling outside the infrastructure ensures administration remains possible during partial service failures.

---

# Dashboard Architecture

The dashboard follows a decoupled API-driven architecture.

```text
External APIs
      │
      ▼
Collection Scripts
      │
      ▼
Olympus Dashboard API (Athena)
      │
      ▼
Homepage (Hestia)
```

### Workflow

1. Automated Python and Shell scripts collect external data.
2. The Dashboard API aggregates all data into a unified JSON response.
3. Homepage consumes the API to render widgets.

### Benefits

- Separation of frontend and backend
- Faster dashboard loading
- Easier maintenance
- Extensible widget development
- Single source of truth for dashboard data

---

# Observability Architecture

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

### Features

- Host monitoring
- VM monitoring
- Capacity planning
- Resource utilization
- Infrastructure dashboards

---

## Logging Pipeline

```text
Containers
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

Provides centralized log aggregation, historical search, and troubleshooting.

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

Alerts cover:

- Host availability
- Service availability
- CPU utilization
- Memory utilization
- Disk capacity
- Infrastructure health

---

# Infrastructure as Code

Infrastructure provisioning and cloud experimentation are managed using Terraform.

```text
Terraform
      │
      ▼
Floci
      ├── S3
      └── DynamoDB
```

### Benefits

- Reproducible deployments
- Local AWS workflow validation
- Zero cloud cost experimentation
- Safe infrastructure testing

---

# Security Architecture

The homelab follows a defense-in-depth approach.

## Principles

- Private-by-default networking
- No unnecessary public exposure
- Tailscale-only remote administration
- Service isolation
- Least-privilege communication

---

## Remote Access

```text
Artemis
      │
      ▼
Tailscale
      │
      ▼
Apollo
      │
      ├── Athena
      └── Hestia
```

Administrative access is performed entirely through Tailscale and SSH.

Apollo provides internal routing using persistent NAT and selectively forwards only required services to the internal network.

---

# Operational Status

| Component | Status |
|----------|--------|
| Apollo | Healthy |
| Athena | Healthy |
| Hestia | Healthy |
| Artemis | Healthy |
| Grafana | Operational |
| Prometheus | Operational |
| Loki | Operational |
| Grafana Alloy | Operational |
| K3s | Operational |
| Homepage | Operational |
| Vaultwarden | Operational |
| Dashboard API | Operational |

---

# Current State

**Phase:** Stable Operational Environment

The Olympus HomeLab currently provides:

- Secure private infrastructure
- Centralized observability
- Kubernetes experimentation
- Infrastructure as Code workflows
- Self-hosted applications
- Automated dashboard integrations
- Remote-first administration
- Production-inspired operational practices

The platform continues to evolve incrementally while maintaining a stable, production-inspired architecture.