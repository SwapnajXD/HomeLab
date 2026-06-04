# Infrastructure Inventory

## Overview

This document serves as the source of truth for all hardware, virtual machines, containers, services, and infrastructure components within the homelab.

---

# Physical Infrastructure

## Apollo

Role:

```text
Primary Hypervisor
```

Platform:

```text
Proxmox VE
```

Responsibilities:

- Virtual Machine Hosting
- LXC Hosting
- Network Routing
- Storage Management

---

# Virtual Infrastructure

## Hestia

Type:

```text
LXC Container
```

Role:

```text
Core Services
```

Services:

- Homepage Dashboard
- Vaultwarden

Network:

```text
10.10.10.2
```

Status:

```text
Production
```

---

## Athena

Type:

```text
Ubuntu Virtual Machine
```

Role:

```text
Operations & Monitoring
```

Network:

```text
10.10.10.10
```

Tailscale:

```text
100.117.35.70
```

Status:

```text
Production
```

---

# Container Inventory

## Core Services

| Service | Purpose | Host |
|----------|----------|----------|
| Homepage | Dashboard | Hestia |
| Vaultwarden | Password Management | Hestia |

---

## Monitoring & Observability

| Service | Purpose | Host |
|----------|----------|----------|
| Grafana | Visualization | Athena |
| Prometheus | Metrics Collection | Athena |
| Loki | Log Aggregation | Athena |
| Promtail | Log Shipping | Athena |
| Node Exporter | System Metrics | Athena |
| Proxmox Exporter | Hypervisor Metrics | Athena |

---

## Management

| Service | Purpose | Host |
|----------|----------|----------|
| Portainer | Container Management | Athena |

---

## Development

| Service | Purpose | Host |
|----------|----------|----------|
| LocalStack | AWS Emulation | Athena |
| Terraform | Infrastructure as Code | Artemis |

---

# Storage Inventory

## Repository

Location:

```text
~/HomeLab
```

Contains:

- Infrastructure Documentation
- Docker Compose Configurations
- Terraform Configurations
- Recovery Procedures
- Network Documentation

---

# Networking Inventory

## Internal Network

| Host | Address |
|--------|----------|
| Hestia | 10.10.10.2 |
| Athena | 10.10.10.10 |

---

## Overlay Network

Technology:

```text
Tailscale
```

Purpose:

```text
Remote Administration
```

---

# Monitoring Coverage

## Metrics

Collected By:

- Prometheus
- Node Exporter
- Proxmox Exporter

---

## Logs

Collected By:

- Promtail

Stored In:

- Loki

Visualized In:

- Grafana

---

# Operational Status

| Component | Status |
|------------|---------|
| Apollo | Active |
| Hestia | Active |
| Athena | Active |
| Homepage | Active |
| Vaultwarden | Active |
| Grafana | Active |
| Prometheus | Active |
| Loki | Active |
| Promtail | Active |
| Portainer | Active |
| LocalStack | Active |

---

# Future Additions

Potential Future Services:

- Immich
- Uptime Kuma
- Gitea
- ESP32 Telemetry Pipeline
- Automated Backup Workflows

---

# Last Updated

Update this document whenever:

- New services are deployed
- Infrastructure changes
- Network changes
- Hardware upgrades