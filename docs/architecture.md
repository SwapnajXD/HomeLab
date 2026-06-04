# Homelab Architecture

## Overview

This homelab is a self-hosted infrastructure platform designed to provide hands-on experience with virtualization, containerization, monitoring, centralized logging, infrastructure-as-code, networking, and disaster recovery.

The environment is built around a Proxmox VE hypervisor and separated into dedicated workloads for core services and operational tooling.

---

## Goals

The primary goals of this homelab are:

- Learn enterprise infrastructure concepts
- Practice Infrastructure as Code (IaC)
- Build experience with observability platforms
- Develop operational troubleshooting skills
- Validate disaster recovery procedures
- Maintain a fully remote-manageable environment
- Create a portfolio project demonstrating DevOps and SRE practices

---

## Infrastructure Components

### Apollo

**Role:** Hypervisor Host

**Platform:** Proxmox VE

**Responsibilities:**

- Virtualization host
- Internal networking gateway
- Tailscale ingress point
- Port forwarding
- VM and LXC orchestration
- Backup scheduling

**Services:**

- Proxmox VE
- Tailscale
- iptables forwarding rules
- vmbr0 bridge network

---

### Hestia

**Role:** Core Services LXC

**IP Address:**

```text
10.10.10.2
```

**Responsibilities:**

- User-facing applications
- Lightweight service hosting

**Services:**

| Service | Purpose |
|----------|----------|
| Homepage | Central dashboard |
| Vaultwarden | Password management |

---

### Athena

**Role:** Operations & Development VM

**IP Addresses:**

```text
10.10.10.10
100.117.35.70 (Tailscale)
```

**Responsibilities:**

- Monitoring
- Logging
- Container management
- Infrastructure testing
- AWS service emulation

**Services:**

| Service | Purpose |
|----------|----------|
| Grafana | Visualization |
| Prometheus | Metrics collection |
| Loki | Log aggregation |
| Promtail | Log shipping |
| Node Exporter | Host metrics |
| Proxmox Exporter | Hypervisor metrics |
| Portainer | Docker management |
| LocalStack | AWS emulation |

---

### Artemis

**Role:** Management Workstation

**Platform:** Arch Linux

**Responsibilities:**

- Remote administration
- Infrastructure as Code development
- Git repository management
- Terraform execution
- Documentation maintenance

---

## Network Topology

```text
Artemis (Arch Linux Laptop)
│
└── Tailscale Tailnet
    │
    └── Apollo (Proxmox VE)
        │
        ├── Hestia (LXC)
        │   ├── Homepage
        │   └── Vaultwarden
        │
        └── Athena (Ubuntu VM)
            ├── Grafana
            ├── Prometheus
            ├── Loki
            ├── Promtail
            ├── Node Exporter
            ├── Proxmox Exporter
            ├── Portainer
            └── LocalStack
```

---

## Monitoring Stack

### Metrics Flow

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

## Logging Stack

### Log Flow

```text
Containers
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

## Infrastructure as Code

Terraform is used to provision resources within LocalStack.

Managed resources:

- S3 Buckets
- DynamoDB Tables

Current managed resources:

```text
tf-homelab-storage-bucket
tf-homelab-metadata
```

---

## Validation Status

| Capability | Status |
|------------|---------|
| Virtualization | Complete |
| Remote Access | Complete |
| Monitoring | Complete |
| Logging | Complete |
| Infrastructure as Code | Complete |
| Dashboard | Complete |
| Recovery Testing | Complete |
| Backup Validation | In Progress |

---

## Future Improvements

Planned enhancements include:

- ESP32 telemetry integration
- Automated backups
- Backup restoration testing
- Alerting and notifications
- CI/CD pipelines
- Infrastructure inventory automation

---

## Repository Reference

Refer to the following documentation:

- `network.md`
- `runbook.md`
- `troubleshooting.md`
- `validation-report.md`
- `disaster-recovery.md`