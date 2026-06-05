# Architecture

## Purpose

This directory contains architecture diagrams and visual representations of the HomeLab environment.

These diagrams provide a high-level overview of infrastructure components, networking, telemetry pipelines, alerting workflows, and recovery procedures. They complement the detailed documentation found in the `docs/` directory.

---

## Overview

The HomeLab is built around a Proxmox VE hypervisor hosting isolated virtual machines and Linux containers for operations, observability, development, and self-hosted services.

---

## Infrastructure Components

### Apollo

**Type:** Proxmox VE Hypervisor

**Responsibilities:**

* Virtualization
* Storage Management
* Network Management
* VM Hosting
* LXC Hosting

---

### Athena

**Type:** Ubuntu Virtual Machine

**Purpose:** Monitoring, observability, automation, and development services.

**Hosted Services:**

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Node Exporter
* Proxmox Exporter
* Portainer
* LocalStack

---

### Hestia

**Type:** Linux Container (LXC)

**Purpose:** Self-hosted applications and user-facing services.

**Hosted Services:**

* Homepage
* Vaultwarden

---

### Artemis

**Type:** Arch Linux Workstation

**Purpose:** Infrastructure administration and management.

**Responsibilities:**

* SSH Administration
* Git Operations
* Terraform Development
* Documentation
* Remote Administration via Tailscale

---

## Network Overview

```text
Artemis
    │
    ▼
Tailscale Mesh VPN
    │
    ▼
Apollo
 ┌──┴──┐
 │     │
 ▼     ▼
Hestia Athena
```

---

## Diagram Inventory

| Diagram                    | Purpose                                       |
| -------------------------- | --------------------------------------------- |
| `architecture-diagram.mmd` | Infrastructure topology and service placement |
| `metrics-flow.mmd`         | Metrics collection and visualization flow     |
| `logging-flow.mmd`         | Log collection and aggregation pipeline       |
| `alerting-flow.mmd`        | Alert routing and notification flow           |
| `recovery-flow.mmd`        | Infrastructure recovery sequence              |

---

## Usage

These diagrams can be viewed directly on platforms that support Mermaid rendering or through local Markdown viewers with Mermaid.js support.

Recommended reading order:

1. `architecture-diagram.mmd`
2. `metrics-flow.mmd`
3. `logging-flow.mmd`
4. `alerting-flow.mmd`
5. `recovery-flow.mmd`

For detailed explanations, refer to:

* `docs/architecture.md`
* `docs/network.md`
* `docs/runbook.md`
* `docs/disaster-recovery.md`

---

## Dependencies

* Mermaid.js
* Markdown renderer with Mermaid support

---

## Maintenance

Update diagrams whenever:

* New hosts are added
* Services are deployed or removed
* Network topology changes
* Monitoring architecture changes
* Recovery procedures are modified

---

## Status

**Documentation Status:** Current

**Architecture State:** Operational

**Last Reviewed:** June 2026
