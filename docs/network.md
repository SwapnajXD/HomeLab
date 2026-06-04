# Network Documentation

## Overview

The homelab network is designed to provide secure remote access, service isolation, and centralized management through a combination of:

- Proxmox Virtualization
- Internal Private Networking
- Tailscale Mesh VPN
- Docker Bridge Networks
- Controlled Port Forwarding

---

# Physical Network

```text
Internet
    │
    ▼
Airtel Fiber Router
    │
    ▼
Apollo (Proxmox Host)
```

Apollo serves as the primary infrastructure host and connects directly to the home network.

---

# Host Inventory

| Host | Role | Platform |
|--------|--------|--------|
| Apollo | Hypervisor | Proxmox VE |
| Hestia | Core Services | LXC |
| Athena | Monitoring & Automation | Ubuntu VM |
| Artemis | Management Workstation | Arch Linux |

---

# Internal Infrastructure Network

## Apollo

Primary Hypervisor

```text
192.168.x.x
```

Responsibilities:

- VM Hosting
- LXC Hosting
- Network Bridging
- Port Forwarding

---

## Hestia

Core Services LXC

```text
10.10.10.2
```

Services:

- Homepage
- Vaultwarden

---

## Athena

Operations VM

```text
10.10.10.10
```

Services:

- Grafana
- Prometheus
- Loki
- Promtail
- Portainer
- LocalStack

---

# Tailscale Overlay Network

Tailscale provides secure remote access without exposing services directly to the public internet.

Benefits:

- No port forwarding required on router
- End-to-end encryption
- Device authentication
- Access from anywhere

---

## Tailscale Nodes

| Node | Purpose |
|--------|--------|
| Artemis | Administration |
| Apollo | Infrastructure Access |
| Athena | Service Access |

---

## Athena Tailscale Address

```text
100.117.35.70
```

Example Service Access:

```text
Grafana
http://100.117.35.70:3001

LocalStack
http://100.117.35.70:4566
```

---

# Proxmox Networking

## Bridge

Current bridge:

```text
vmbr0
```

Purpose:

- Connect VMs and LXCs
- Internal infrastructure communication
- Service routing

---

# Docker Networking

Athena uses Docker bridge networks for service isolation.

Current stacks:

```text
telemetry
localstack
```

Example:

```text
telemetry-net
```

Containers communicate internally using Docker DNS.

Example:

```text
prometheus
loki
grafana
```

without requiring external IP addresses.

---

# Monitoring Traffic Flow

```text
Apollo
│
├── Node Exporter
│
├── Proxmox Exporter
│
▼
Prometheus
│
▼
Grafana
```

---

# Logging Traffic Flow

```text
Docker Containers
        │
        ▼
Promtail
        │
        ▼
Loki
        │
        ▼
Grafana
```

---

# Infrastructure as Code Traffic Flow

```text
Artemis
    │
    ▼
Terraform
    │
    ▼
Tailscale Tunnel
    │
    ▼
Athena
    │
    ▼
LocalStack
```

Managed resources:

```text
tf-homelab-storage-bucket
tf-homelab-metadata
```

---

# Port Inventory

## Athena

| Service | Port |
|----------|----------|
| Grafana | 3001 |
| Prometheus | 9090 |
| Loki | 3100 |
| Node Exporter | 9100 |
| Proxmox Exporter | 9221 |
| LocalStack | 4566 |

---

## Hestia

| Service | Port |
|----------|----------|
| Homepage | 3000 |
| Vaultwarden | 8080 |

---

# Firewall Philosophy

The homelab follows the principle of:

```text
Default:
    Private

Access:
    Through Tailscale

Public Exposure:
    None
```

No services are intentionally exposed directly to the public internet.

---

# Security Controls

Implemented:

- Tailscale authentication
- Encrypted overlay networking
- Service isolation
- Internal-only monitoring stack
- Infrastructure separation between workloads

---

# Future Enhancements

Planned improvements:

- Tailscale ACL policies
- Automated network inventory
- Service discovery
- Network monitoring dashboards
- Backup VPN node

---

# Related Documentation

- architecture.md
- runbook.md
- troubleshooting.md
- validation-report.md