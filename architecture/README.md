# Architecture Diagrams

## Purpose

This directory contains the visual architecture diagrams and Mermaid (`.mmd`) flowcharts that document the design, communication paths, and operational workflows of the HomeLab environment.

These diagrams complement the detailed documentation found in the `docs/` directory by providing a visual representation of the infrastructure, observability stack, alerting mechanisms, and recovery procedures.

**Last verified against live systems:** 2026-07-18 (see `docs/postmortems.md` for the full audit).

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

**Type:** Proxmox VE 9.2.2 Hypervisor

**Hardware:** AMD Ryzen 7 3700X (8 cores/16 threads), 16GB DDR4-3200 (1 of 4 DIMM slots populated), a 238.5GB NVMe drive hosting the Proxmox LVM-thin pool, a 232.9GB SATA drive as a secondary storage pool, and an idle NVIDIA GTX 1660 Super (no PCIe passthrough currently configured — a real future upgrade candidate, not just a hypothetical). Full spec in `docs/inventory.md`.

**Responsibilities:**

* Virtualization platform
* VM and LXC lifecycle management
* Storage management
* Virtual networking (`vmbr0`)
* Persistent NAT gateway + DNAT port forwarding
* Guest autostart policies

> **In progress:** Apollo's firewall/NAT layer is being migrated from `iptables` to `nftables`. Diagrams and rule references below reflect the current `iptables` configuration until that completes — see `docs/network.md` and `docs/postmortems.md`.

---

### Athena

**Type:** Ubuntu Server 20.04.6 LTS Virtual Machine (4 cores, 3.8GB RAM, 32GB disk)

**Purpose:** Monitoring, observability, Kubernetes, automation, and supporting services.

**Hosted Services (confirmed live, 2026-07-18):**

* Grafana
* Prometheus
* Loki
* Grafana Alloy
* Node Exporter
* Proxmox Exporter
* cAdvisor
* Glances
* Portainer
* K3s (single-node Kubernetes lab, v1.35.5+k3s1, remotely managed via `kubectl`; no Ingress controller deployed)
* Floci (local AWS emulation for Terraform — **started on-demand, not continuously running**)

---

### Hestia

**Type:** Alpine Linux Container (LXC) — 1 core, 512MB RAM, 8GB disk — excluded from the Tailscale mesh, reachable only through Apollo's port forwarding

**Purpose:** Minimal, self-hosted, user-facing services — plus its own local observability footprint.

**Hosted Services (confirmed live, 2026-07-18):**

* Homepage — stock service-discovery widgets + a lightweight, purely cosmetic `custom.css` theme (`custom.js` confirmed empty)
* Vaultwarden — HTTPS only
* Grafana Alloy — per-host log collection, forwarding to the central Loki on Athena
* Node Exporter — per-host system metrics
* Portainer Agent — lets Athena's central Portainer manage Hestia's containers remotely

> **Correction:** earlier documentation listed Hestia as running only Homepage + Vaultwarden. A live audit confirmed it also runs its own Alloy/Node Exporter/Portainer Agent — the diagrams below reflect this.
>
> Homepage previously ran a custom "Olympus" dashboard widget backed by a FastAPI aggregation service on Athena. Both were **decommissioned from active deployment** (2026-07-10) in favor of this simpler setup — but the Dashboard API's source code was intentionally **retained in the repository** (`docker-compose/dashboard-api/`) as a portfolio artifact, not deleted. See `docs/architecture.md` and `docs/postmortems.md` for the full history.

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
* Real service distribution across hosts, including Hestia's own monitoring footprint and the K3s lab
* Network segmentation (Hestia isolated from Tailscale, reached via DNAT)
* Administrative access paths

---

### `metrics-flow.mmd`

**Purpose:**

Documents the metrics collection and visualization pipeline.

**Flow:**

```text
Node Exporter (Athena + Hestia)
        │
        ▼
Proxmox Exporter / cAdvisor
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
Docker Containers (Athena + Hestia)
        │
        ▼
Grafana Alloy (per-host)
        │
        ▼
Loki (Athena)
        │
        ▼
Grafana Explore
```

**Status:** Fully operational. A Docker log discovery gap that previously limited ingestion to 2 of 9 containers (opened 2026-07-05) is **resolved** — confirmed via live audit on 2026-07-18 that all 12 running containers across both hosts are being ingested correctly.

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

**Note:** each `.mmd` file contains raw Mermaid syntax only — no markdown code fences. If you ever hand-edit one of these, don't wrap it in ` ```mermaid ` fences; that will break GitHub's native rendering (this bit us once — see `docs/postmortems.md`).

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

Keeping these diagrams current ensures that the visual documentation accurately reflects the operational environment — a live infrastructure audit (2026-07-18) found real drift between prior documentation and actual running systems, which is exactly the kind of thing periodic re-verification against live systems is meant to catch.

---

## Status

**Documentation Status:** Current — reconciled against live infrastructure audit

**Architecture State:** Operational

**Last Reviewed:** 2026-07-18

**Recent Changes:** Live audit confirmed Hestia's and Athena's full real service inventories (previously undercounted); Docker log discovery gap in Grafana Alloy resolved; Traefik confirmed not deployed in K3s; Floci confirmed on-demand; real Apollo hardware specs documented; Apollo's NAT layer migration from `iptables` to `nftables` in progress; Dashboard API decommissioned from deployment with source code intentionally retained in the repository.
