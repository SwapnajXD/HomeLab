# Infrastructure Inventory

## Overview

This document serves as the authoritative inventory of the Olympus HomeLab environment. It documents all physical hardware, virtual infrastructure, containerized services, Kubernetes workloads, networking components, automation pipelines, and operational assets.

The inventory acts as the single source of truth for infrastructure management, troubleshooting, capacity planning, and disaster recovery.

---

# Environment Summary

| Category | Count | Status |
|----------|------:|--------|
| Physical Nodes | 2 | Healthy |
| Hypervisors | 1 | Operational |
| Virtual Machines | 1 | Healthy |
| LXC Containers | 1 | Healthy |
| Docker Services | 12+ | Operational |
| Kubernetes Cluster | 1 | Healthy |
| Kubernetes Pods | 5+ | Running |
| Monitoring Components | 6 | Healthy |
| Self-Hosted Applications | 2 | Operational |
| Automation Pipelines | 6 | Operational |

---

# Infrastructure Topology

```text
                    Artemis
           (Management Workstation)
                    │
        ───────── Tailscale ─────────
                    │
                Apollo
          (Proxmox VE Hypervisor)
                    │
      ┌─────────────┴─────────────┐
      │                           │
 VM 100: Athena             CT 101: Hestia
 Ubuntu Operations VM      Alpine Application LXC
      │                           │
 Docker + K3s                 Docker Compose
      │                           │
Dashboard API                Homepage
Grafana                     Vaultwarden
Prometheus
Loki
Grafana Alloy
Portainer
Floci
```

---

# Physical Infrastructure

## Apollo

**Role:** Primary Infrastructure Host

| Property | Value |
|----------|-------|
| Platform | Proxmox VE 8.x |
| Type | Type-1 Hypervisor |
| Status | Healthy |

### Responsibilities

- Virtual Machine Hosting
- LXC Hosting
- Storage Management
- Virtual Networking
- Persistent NAT Gateway
- DNAT Port Forwarding
- Bridge Management (`vmbr0`)

### Hosted Workloads

| ID | Workload | Type |
|----|----------|------|
| 100 | Athena | Ubuntu VM |
| 101 | Hestia | Alpine LXC |

---

## Artemis

**Role:** Management Workstation

| Property | Value |
|----------|-------|
| Platform | Arch Linux |
| Type | Physical Laptop |
| Status | Healthy |

### Responsibilities

- SSH Administration
- kubectl Management
- Terraform Operations
- Git Repository Management
- Documentation
- Remote Infrastructure Management
- Browser Access to Internal Services

---

# Virtual Infrastructure

## Athena (VM 100)

**Role:** Operations, Observability & Kubernetes Platform

| Property | Value |
|----------|-------|
| OS | Ubuntu Server |
| Runtime | Docker Compose + K3s |
| LAN IP | `10.10.10.10` |
| Status | Healthy |

### Key Configuration

- cgroup v2 Enabled
- Docker Compose Runtime
- Single-node K3s Cluster
- Dashboard API Backend
- Infrastructure Automation Host

### Hosted Services

| Service | Port | Purpose |
|---------|------|---------|
| Grafana | 3001 | Dashboards & Alerting |
| Prometheus | 9090 | Metrics Collection |
| Loki | 3100 | Log Aggregation |
| Grafana Alloy | Host | Log Collection |
| Node Exporter | Internal | System Metrics |
| Proxmox Exporter | Internal | Hypervisor Metrics |
| Portainer | 9443 | Container Management |
| Olympus Dashboard API | 8000 | Homepage Backend |
| Floci | 4566 | AWS Emulation |
| K3s Control Plane | 6443 | Kubernetes API |

## Hestia (CT 101)

**Role:** Frontend Application Platform

| Property | Value |
|----------|-------|
| OS | Alpine Linux |
| Runtime | Docker Compose |
| LAN IP | `10.10.10.2` |
| Tailscale | Disabled |
| Status | Healthy |

> Hestia is intentionally isolated from the Tailscale mesh and is accessible only through Apollo's port forwarding rules.

### Hosted Services

| Service | Port | Purpose |
|---------|------|---------|
| Homepage | 3000 | Infrastructure Dashboard |
| Vaultwarden | 8080 | Password Management |

---

# Kubernetes Inventory

## K3s Cluster

| Property | Value |
|----------|-------|
| Distribution | K3s |
| Topology | Single Node |
| Host | Athena |
| Status | Healthy |

### Features

- Kubernetes Control Plane
- Worker Node
- CoreDNS
- Metrics Server
- Traefik
- Portainer Agent
- Learning Namespace (`artemis-lab`)

### Management

Remote administration is performed from Artemis using:

```bash
kubectl
```

The Kubernetes API is accessed through Athena's LAN IP to match certificate SANs.

---

# Monitoring & Observability

## Grafana

**Purpose**

- Dashboards
- Metrics Visualization
- Log Exploration
- Alerting

**Status:** Healthy

---

## Prometheus

**Purpose**

- Metrics Collection
- Time-Series Database
- Alert Evaluation

### Monitored Targets

- Node Exporter
- Proxmox Exporter
- Docker Services
- K3s Components

**Status:** Healthy

---

## Loki

**Purpose**

- Centralized Log Storage
- Log Search
- Historical Retention

**Status:** Healthy

---

## Grafana Alloy

**Purpose**

- Docker Log Discovery
- Log Collection
- Log Forwarding

**Destination**

```
Docker
    ↓
Grafana Alloy
    ↓
Loki
    ↓
Grafana
```

**Status:** Healthy

---

## Node Exporter

**Metrics**

- CPU
- Memory
- Disk
- Filesystem
- Network

**Status:** Healthy

---

## Proxmox Exporter

**Metrics**

- Hypervisor
- Virtual Machines
- Containers
- Storage
- CPU
- Memory

**Status:** Healthy

---

# Application Inventory

## Homepage

| Property | Value |
|----------|-------|
| Host | Hestia |
| Port | 3000 |
| Access | DNAT via Apollo |

### Features

- Service Dashboard
- Dynamic Widgets
- Olympus Dashboard API Integration

---

## Vaultwarden

| Property | Value |
|----------|-------|
| Host | Hestia |
| Port | 8080 |
| Protocol | HTTPS Only |

### Notes

- Persistent Storage
- Password Management
- Accessible only through Apollo port forwarding

---

## Olympus Dashboard API

| Property | Value |
|----------|-------|
| Host | Athena |
| Port | 8000 |

### Responsibilities

- Data Aggregation
- Widget Backend
- JSON Generation
- Homepage API
- Single Source of Truth

---

## Portainer

| Property | Value |
|----------|-------|
| Host | Athena |
| Port | 9443 |

### Responsibilities

- Docker Management
- Kubernetes Visibility
- Container Monitoring

---

## Floci

| Property | Value |
|----------|-------|
| Host | Athena |
| Port | 4566 |

### Services

- Amazon S3
- DynamoDB

**Purpose:** Local AWS emulation for Terraform development.

# Automation Pipelines

Olympus Dashboard V2 centralizes data collection on Athena, where scheduled fetch scripts gather information from external APIs and expose it through the Dashboard API. Concurrency is controlled using `flock` to prevent overlapping executions.

| Pipeline | Frequency | Source | Output |
|----------|-----------|--------|--------|
| LastFM | Every 1 Minute | Last.fm API | Track, Artist, Album, Album Art |
| Media Hero | Every 1 Minute | GitHub Wallpapers | Dashboard Hero Image |
| Weather | Every 15 Minutes | wttr.in | Current Weather |
| Investments | Every 30 Minutes | Financial APIs | GoldBeES & LiquidCase Prices |
| Pokémon | Every 6 Hours | PokeAPI | Pokémon Data & Flavor Text |
| Anime | Manual | MyAnimeList | User Statistics |

### Pipeline Flow

```text
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
Homepage Dashboard
```

---

# Networking Inventory

## Internal Network

| Component | Value |
|----------|-------|
| LAN Subnet | `10.10.10.0/24` |
| Gateway | Apollo |
| Bridge | `vmbr0` |

---

## Tailscale Mesh

### Connected Nodes

- Artemis
- Apollo
- Athena

### Purpose

- Secure Remote Administration
- SSH Access
- kubectl Management
- Web UI Access

---

## NAT Gateway (Apollo)

### Outbound NAT

Provides internet access for internal workloads.

```text
10.10.10.0/24
        │
MASQUERADE
        │
Internet
```

---

### Inbound Port Forwarding

| External Port | Destination | Service |
|--------------:|------------|---------|
| 3000 | Hestia | Homepage |
| 8080 | Hestia | Vaultwarden (HTTPS) |

---

## Kubernetes Networking

| Component | Value |
|----------|-------|
| API Port | 6443 |
| Access Method | Athena LAN IP |
| Cluster Type | Single Node |

---

# Security Inventory

## Remote Access

- Tailscale Zero-Trust Network
- SSH Key Authentication
- No Public SSH Exposure

---

## Service Isolation

- Hestia excluded from Tailscale
- Frontend accessible only through Apollo
- Internal services remain on the private LAN

---

## Dashboard Security

- Backend logic centralized on Athena
- Homepage acts as a frontend only
- JSON generated safely using `jq`
- Cron jobs protected using `flock`

---

# Recovery Readiness

| Component | Status |
|----------|--------|
| VM Autostart | Enabled |
| LXC Autostart | Enabled |
| Disaster Recovery Runbook | Complete |
| Health Verification Guide | Complete |
| Infrastructure Validation | Complete |
| NAT Persistence Documented | Yes |
| Operational Documentation | Complete |

---

# Operational Status

| Component | Status |
|----------|--------|
| Apollo | Healthy |
| Artemis | Healthy |
| Athena | Healthy |
| Hestia | Healthy |
| Kubernetes | Healthy |
| Grafana | Healthy |
| Prometheus | Healthy |
| Loki | Healthy |
| Grafana Alloy | Healthy |
| Homepage | Healthy |
| Vaultwarden | Healthy |
| Dashboard API | Healthy |
| Floci | Healthy |
| Automation Pipelines | Healthy |
| Network Routing | Operational |
| Observability | Operational |

---

# Summary

The Olympus HomeLab consists of a production-inspired virtualized environment built around Proxmox VE, Docker, and K3s. Infrastructure responsibilities are distributed between Athena (operations, observability, and backend services) and Hestia (frontend applications), while Apollo provides virtualization, networking, and gateway services.

The environment includes centralized monitoring, logging, Infrastructure as Code workflows, secure remote administration through Tailscale, automated dashboard data aggregation, and comprehensive operational documentation covering architecture, recovery, validation, troubleshooting, and health verification.

**Overall Infrastructure Status:** Healthy and Operational

**Operational Readiness:** Fully Validated