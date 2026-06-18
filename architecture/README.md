# Architecture Diagrams

## Purpose

This directory contains the visual architecture diagrams and Mermaid (`.mmd`) flowcharts that document the design, communication paths, and operational workflows of the HomeLab environment.

These diagrams complement the detailed documentation found in the `docs/` directory by providing a visual representation of the infrastructure, observability stack, alerting mechanisms, and recovery procedures.

---

## Architecture Overview

The HomeLab follows a layered architecture designed to emulate enterprise infrastructure patterns while remaining lightweight and maintainable.

The environment is built around a Proxmox VE hypervisor hosting isolated workloads for operations, observability, and self-hosted services.

```text
Artemis
    │
    ▼
Tailscale Mesh VPN
    │
    ▼
Apollo (Proxmox VE)
 ┌──┴─────────┐
 │            │
 ▼            ▼
Hestia      Athena
(LXC)         (VM)
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
* Guest autostart policies

---

### Athena

**Type:** Ubuntu Server Virtual Machine

**Purpose:** Monitoring, observability, automation, and supporting services.

**Hosted Services:**

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Node Exporter
* Proxmox Exporter
* Portainer
* LocalStack (Terraform experimentation)

---

### Hestia

**Type:** Linux Container (LXC)

**Purpose:** Self-hosted and user-facing services.

**Hosted Services:**

* Homepage
* Vaultwarden

---

### Artemis

**Type:** Arch Linux Workstation

**Purpose:** Infrastructure administration and development.

**Responsibilities:**

* SSH administration
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
* Service distribution across hosts
* Network segmentation
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

Documents the expected recovery sequence following a complete host reboot or power restoration event.

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
        ▼
Athena Autostarts
        │
        ▼
Hestia Autostarts
        │
        ▼
Docker Services Recover
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
* `docs/runbook.md`
* `docs/disaster-recovery.md`
* `docs/validation-report.md`

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

**Last Reviewed:** June 2026
