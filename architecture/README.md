# Architecture Diagrams

## Purpose

This directory contains the visual architecture diagrams and Mermaid (`.mmd`) flowcharts that document the design, communication paths, and operational workflows of the HomeLab environment.

These diagrams complement the detailed documentation found in the `docs/` directory by providing a visual representation of the infrastructure, observability stack, alerting mechanisms, and recovery procedures.

---

## Architecture Overview

The HomeLab follows a layered architecture designed to emulate enterprise infrastructure patterns while remaining lightweight and maintainable.

The environment is built around a Proxmox VE hypervisor hosting isolated workloads for operations, observability, Kubernetes experimentation, and self-hosted services.

```text
Artemis
    │
    ▼
Tailscale Mesh VPN
    │
    ▼
Apollo (Proxmox VE)
    │
    ▼
Athena (VM)
    │
    ▼ (DNAT via Apollo — not on the Tailnet)
Hestia (LXC)
```

---

## Infrastructure Components

### Apollo

**Type:** Proxmox VE Hypervisor

**Responsibilities:**

* Virtualization platform
* VM and LXC lifecycle management
* Storage management
* Virtual networking (`vmbr0`)
* Persistent NAT gateway + DNAT port forwarding
* Guest autostart policies

---

### Athena

**Type:** Ubuntu Server Virtual Machine

**Purpose:** Monitoring, observability, Kubernetes, automation, and supporting services.

**Hosted Services:**

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Node Exporter
* Proxmox Exporter
* Portainer
* K3s (single-node Kubernetes lab, remotely managed via `kubectl`)
* Floci (local AWS emulation for Terraform)

---

### Hestia

**Type:** Linux Container (LXC), excluded from the Tailscale mesh, reachable only through Apollo's port forwarding

**Purpose:** Minimal, self-hosted, user-facing services.

**Hosted Services:**

* Homepage — **stock configuration**, no custom widget or backend API
* Vaultwarden — HTTPS only

> Homepage previously ran a custom "Olympus" dashboard widget backed by a FastAPI aggregation service on Athena. Both were fully decommissioned (2026-07-10) in favor of this simpler, lower-maintenance setup. See `docs/architecture.md` and `docs/postmortems.md` for the full history.

---

### Artemis

**Type:** Arch Linux Workstation

**Purpose:** Infrastructure administration and development.

**Responsibilities:**

* SSH administration
* `kubectl` / Kubernetes management
* Git operations
* Terraform development
* Documentation maintenance
* Remote management via Tailscale

---

## Diagram Inventory

### `architecture-diagram.mmd`

**Purpose:**

Provides the high-level infrastructure topology and service placement.

**Illustrates:**

* Hypervisor and guest relationships
* Service distribution across hosts, including the K3s lab
* Network segmentation (Hestia isolated from Tailscale, reached via DNAT)
* Administrative access paths

---

### `metrics-flow.mmd`

**Purpose:**

Documents the metrics collection and visualization pipeline.

**Flow:**

```text
Node Exporter
        │
        ▼
Proxmox Exporter
        │
        ▼
Prometheus
        │
        ▼
Grafana Dashboards
```

---

### `logging-flow.mmd`

**Purpose:**

Documents centralized log aggregation.

**Flow:**

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
Grafana Explore
```

**Status:** Functional but incomplete — Alloy is currently only discovering logs from 2 of 9 running containers on Athena. See `docs/troubleshooting.md`.

---

### `alerting-flow.mmd`

**Purpose:**

Illustrates the alert evaluation and notification workflow.

**Flow:**

```text
Prometheus Rules
        │
        ▼
Grafana Alerting
        │
        ▼
Telegram Notifications
```

---

### `recovery-flow.mmd`

**Purpose:**

Documents the expected recovery sequence following a complete host reboot or power restoration event, including Kubernetes cluster recovery.

**Flow:**

```text
Power Restored
        │
        ▼
Apollo Boots
        │
        ▼
Network Initialization
        │
        ├──────────────┐
        ▼              ▼
Athena Autostarts   Hestia Autostarts
        │              │
        ├── Telemetry Stack Recovers
        ├── K3s Cluster Ready
        │              │
        │       Core Services Recover
        ▼              ▼
     Tailscale Reconnects
        │
        ▼
Infrastructure Operational
```

---

## Viewing the Diagrams

These diagrams can be rendered using:

* GitHub's native Mermaid support
* Markdown viewers with Mermaid.js support
* Mermaid Live Editor

Recommended reading order:

1. `architecture-diagram.mmd`
2. `metrics-flow.mmd`
3. `logging-flow.mmd`
4. `alerting-flow.mmd`
5. `recovery-flow.mmd`

---

## Related Documentation

For detailed operational guidance and implementation details, refer to:

* `docs/architecture.md`
* `docs/network.md`
* `docs/inventory.md`
* `docs/runbook.md`
* `docs/troubleshooting.md`
* `docs/disaster-recovery.md`
* `docs/validation-report.md`
* `docs/postmortems.md`
* `docs/changelog.md`
* `docs/project-timeline.md`

---

## Maintenance Guidelines

Update the diagrams whenever:

* Hosts are added, removed, or repurposed
* Services are deployed or decommissioned
* Network topology changes
* Monitoring or logging pipelines change
* Alerting workflows are modified
* Recovery procedures are updated

Keeping these diagrams current ensures that the visual documentation accurately reflects the operational environment.

---

## Status

**Documentation Status:** Current

**Architecture State:** Operational

**Last Reviewed:** 2026-07-18

**Recent Changes:** LocalStack replaced with Floci; K3s Kubernetes lab added; custom Homepage dashboard widget and its backend Dashboard API fully decommissioned (Homepage now runs stock).
