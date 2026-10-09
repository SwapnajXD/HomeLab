# Post-migration HomeLab report

Operator-supplied account incorporated on **2026-10-09** from `update.txt`; the exact migration date was not supplied. This supersedes the September 12–14 baseline where it describes later changes. No live inspection was performed. The source account below is retained to preserve all reported details and intentions; statements about current health refer to its reporting time.

Interpretation limits: the supplied Proxmox VE `9.2.0` and `pve-manager 9.2.20` strings are recorded verbatim, not reconciled against a host export. VM 102 CPU, RAM, disk allocation and kernel were not supplied. Removal of migration backups does not establish which other historical archives still exist. Olympus is an intended workload, not a confirmed deployment; general Grafana capabilities do not establish Kubernetes telemetry coverage.

Related: [Apollo incident](apollo-power-loss-2026-09.md), [current infrastructure](../infrastructure.md), [recovery](../disaster-recovery.md).

---

# Supplied HomeLab account

## 1. Overview

The homelab is a small self-hosted infrastructure environment built around a single physical **Proxmox** server and multiple virtual machines. Its primary purpose is hands-on learning and experimentation with:

* Linux system administration
* Docker and Docker Compose
* Kubernetes / K3s
* Infrastructure monitoring
* Centralized logging
* Networking and Tailscale
* Application deployment
* Infrastructure observability
* Cloud/DevOps practices

The architecture intentionally separates **infrastructure**, **applications**, and **observability** rather than putting every service on a single machine.

The current architecture consists of:

```text
                         ┌─────────────────────┐
                         │       Artemis       │
                         │ Management Client    │
                         │ SSH / kubectl / Git  │
                         └──────────┬──────────┘
                                    │
                              Tailscale / LAN
                                    │
┌───────────────────────────────────┴────────────────────────────────────┐
│                                Apollo                                 │
│                         Physical Proxmox Host                          │
│                         10.10.10.1 / 192.168.1.20                     │
│                                                                       │
│   ┌────────────────────────┐        ┌──────────────────────────────┐  │
│   │       Hermes           │        │            Athena             │  │
│   │    VM 101              │        │            VM 102              │  │
│   │    Applications        │        │         Observability          │  │
│   │                        │        │                                │  │
│   │ K3s                    │        │ Prometheus                     │  │
│   │ Traefik                │        │ Grafana                        │  │
│   │ Floci / Docker         │        │ Loki                           │  │
│   │ cAdvisor               │        │ Alloy                          │  │
│   │ Alloy                  │───────►│ Node Exporter                  │  │
│   │                        │        │ cAdvisor                       │  │
│   └────────────────────────┘        │ Proxmox Exporter                │  │
│                                     │ Glances                         │  │
│                                     └──────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────┘
```

---

# 2. Physical Infrastructure — Apollo

## Apollo

**Apollo** is the physical infrastructure host and the foundation of the homelab.

### Operating system

* Debian 13 (Trixie)
* Proxmox VE 9.2.0
* Kernel: `7.0.14-19-pve`

### Proxmox components

Current versions include:

* `pve-manager 9.2.20`
* `pve-qemu-kvm 11.0.3-3`
* `qemu-server 9.2.8`
* Ceph `19.2.6-pve4`
* ZFS `2.4.4-pve1`

### Network

Apollo has:

```text
LAN:
192.168.1.20

Internal VM network:
10.10.10.1/24

Tailscale:
100.81.86.51
```

The `10.10.10.0/24` network is used for communication between the virtual machines.

Apollo's Proxmox bridge is:

```text
vmbr0
└── 10.10.10.1/24
```

### Current VMs

Apollo currently runs two VMs:

| VM ID | Name   | Purpose            |
| ----: | ------ | ------------------ |
|   101 | Hermes | K3s + applications |
|   102 | Athena | Observability      |

There is **no Proxmox cluster**. Apollo is a standalone Proxmox host.

This means the environment does not provide physical high availability. Apollo remains a single physical point of failure.

---

# 3. Hermes — Kubernetes and Application Host

## Hermes

**Hermes** is the primary application and Kubernetes learning environment.

It is a VM running on Apollo.

### Network

```text
Internal:
10.10.10.11

Tailscale:
100.91.200.31
```

### Kubernetes

Hermes currently runs a **single-node K3s cluster**.

```text
K3s version:
v1.36.4+k3s1
```

Current node:

```text
NAME     STATUS   ROLES
hermes   Ready    control-plane
```

Hermes acts as both:

* Kubernetes control-plane
* Kubernetes worker

because this is currently a single-node cluster.

The cluster uses K3s's built-in components, including **Traefik** for ingress.

### Kubernetes purpose

K3s on Hermes is intended primarily for:

* Kubernetes learning
* application deployment
* container orchestration
* service networking
* ingress / Gateway experimentation
* configuration and secrets
* persistent storage
* eventually running real homelab applications

The cluster is intentionally kept relatively simple while Kubernetes concepts are being learned.

Multi-node Kubernetes is postponed until another suitable node is available.

---

# 4. Docker on Hermes

Docker is also intentionally used on Hermes.

This is important because **not every application is being migrated to Kubernetes**.

The current architecture deliberately separates:

```text
Kubernetes workloads
        +
Docker Compose workloads
```

rather than forcing everything into K3s.

## Floci

**Floci** is currently deployed with Docker Compose rather than K3s.

Its application data/configuration is under:

```text
~/apps/floci/
```

The current structure includes:

```text
~/apps/floci/
├── compose/
├── compose.yml
├── data/
│   ├── resourceexplorer2-default-views.json
│   ├── resourceexplorer2-indexes.json
│   ├── resourceexplorer2-setup-tasks.json
│   ├── resourceexplorer2-views.json
│   └── tls/
│       ├── floci-selfsigned.crt
│       ├── floci-selfsigned.key
│       └── floci-selfsigned.metadata.json
```

The primary Floci container is:

```text
floci/floci:latest
```

It exposes:

```text
4566
6379–6399
7001–7099
```

Floci remains deliberately outside Kubernetes.

---

# 5. Hermes Container Telemetry

Hermes also runs **cAdvisor** for container-level metrics.

Current cAdvisor version:

```text
0.60.5
```

This allows the observability stack on Athena to collect information about containers running on Hermes.

The architecture is:

```text
Hermes Docker
     │
     ▼
cAdvisor
     │
     ▼
Prometheus on Athena
     │
     ▼
Grafana on Athena
```

---

# 6. Hermes Centralized Logging

Hermes runs **Grafana Alloy** as a system service.

Alloy collects Docker container logs from Hermes through the Docker socket.

The pipeline is:

```text
Docker containers
       │
       ▼
Grafana Alloy
       │
       │ Tailscale
       ▼
Athena Loki
       │
       ▼
Grafana
```

Current Alloy Loki destination:

```text
http://100.93.224.83:3100/loki/api/v1/push
```

Hermes adds:

```text
host="hermes"
```

as an external label.

Alloy's HTTP interface is available through Hermes's Tailscale address:

```text
100.91.200.31:12345
```

The logging pipeline has been explicitly tested end-to-end using fresh Docker logs.

---

# 7. Athena — Observability Server

## Athena

**Athena** is now the dedicated observability VM.

The previous Athena VM was VM 100 running Ubuntu 20.04. That VM was retired and deleted after the migration.

The current Athena is:

```text
VM ID: 102
OS: Ubuntu Server 24.04.5 LTS
```

### Network

```text
Internal:
10.10.10.10

Tailscale:
100.93.224.83
```

Athena therefore occupies the same internal address previously used by the old Athena instance.

---

# 8. Athena Observability Stack

Athena hosts the centralized monitoring and logging stack.

Current services:

```text
Prometheus
Grafana
Loki
Grafana Alloy
Node Exporter
cAdvisor
Proxmox Exporter
Glances
```

They are deployed using Docker Compose.

Configuration is located under:

```text
~/homelab/docker-compose/telemetry/
```

The stack consists of:

```text
                    ┌───────────────┐
                    │   Prometheus  │
                    └───────┬───────┘
                            │
             ┌──────────────┼───────────────┐
             │              │               │
             ▼              ▼               ▼
          Hermes         Athena          Apollo
          metrics        metrics        Proxmox
             │                              │
             └──────────────┬───────────────┘
                            ▼
                         Grafana
```

For logs:

```text
Hermes Docker
      │
      ▼
Hermes Alloy
      │
      ▼
Tailscale
      │
      ▼
Athena Loki
      │
      ▼
Grafana
```

---

# 9. Prometheus

Prometheus is the central metrics database.

It collects metrics from:

* Hermes
* Hermes cAdvisor
* Athena
* Athena cAdvisor
* Prometheus itself
* Proxmox
* other configured scrape targets

The current Prometheus target set has been verified with **7 targets up**.

The important architectural distinction is:

> Prometheus collects metrics; Grafana visualizes them.

---

# 10. Grafana

Grafana is the main visualization interface for the homelab.

It provides dashboards for:

* infrastructure
* VM resources
* Kubernetes
* containers
* system resources
* logs
* application telemetry

Grafana is intentionally used as the **detailed observability interface**.

This means other dashboards, such as Olympus, do not need to duplicate Grafana's full monitoring functionality.

---

# 11. Loki

Loki is the centralized log storage system.

Athena's Loki receives logs from Hermes through Alloy over Tailscale.

The current verified path is:

```text
Hermes Docker
    ↓
Hermes Alloy
    ↓
Tailscale
    ↓
Athena Loki
    ↓
Grafana / Loki API
```

Fresh Docker log entries from Hermes have been successfully queried from Athena, confirming the complete pipeline.

---

# 12. Grafana Alloy

Alloy is used in two roles within the architecture.

### Hermes

Hermes Alloy:

* discovers Docker containers
* reads Docker logs
* attaches labels
* forwards logs to Athena Loki

### Athena

Athena Alloy is part of the observability stack and handles telemetry collection according to its Compose configuration.

This gives the homelab a dedicated telemetry pipeline without requiring every application to directly communicate with Grafana or Loki.

---

# 13. Node Exporter

Node Exporter provides host-level Linux metrics.

It allows Prometheus/Grafana to monitor:

* CPU
* memory
* filesystem usage
* disk activity
* network activity
* system statistics

Node Exporter runs on Athena and provides host metrics for the observability VM.

---

# 14. cAdvisor

cAdvisor provides container-level metrics.

It exposes information about Docker containers such as:

* CPU usage
* memory usage
* network activity
* filesystem usage
* container state

Hermes has cAdvisor installed directly, allowing Athena's Prometheus to monitor the Docker workloads running on Hermes.

Athena also runs cAdvisor for its own Docker workloads.

---

# 15. Proxmox Exporter

The Proxmox exporter allows Prometheus to collect infrastructure metrics from Apollo.

This gives the observability stack visibility into the Proxmox environment.

The resulting hierarchy is:

```text
Apollo
├── Proxmox
├── VM 101 Hermes
└── VM 102 Athena
```

with Prometheus collecting Proxmox-level information through the exporter.

---

# 16. Glances

Glances provides an additional system-level monitoring interface on Athena.

It is useful for quick interactive inspection of:

* CPU
* memory
* processes
* network
* disks
* containers

It complements Prometheus/Grafana rather than replacing them.

---

# 17. Networking

The homelab uses multiple network layers.

### Physical/LAN network

Apollo is connected to the main LAN:

```text
Apollo
192.168.1.20
```

### Internal VM network

The virtual machines communicate over:

```text
10.10.10.0/24
```

Current addresses:

```text
Apollo   10.10.10.1
Athena   10.10.10.10
Hermes   10.10.10.11
```

### Tailscale

Tailscale provides remote/private connectivity between the homelab systems.

Current relevant addresses:

```text
Apollo    100.81.86.51
Hermes    100.91.200.31
Athena    100.93.224.83
Artemis   100.100.252.87
```

Tailscale is particularly useful for:

* remote SSH
* Kubernetes administration
* Alloy interfaces
* telemetry traffic
* management access

The Hermes → Athena Loki connection currently uses Tailscale.

---

# 18. Artemis — Management Workstation

**Artemis** is the management/client machine rather than a server in the homelab.

It is used for:

* SSH
* `kubectl`
* Git
* Kubernetes administration
* interacting with the infrastructure remotely

The management model is therefore:

```text
Artemis
   │
   ├── SSH → Apollo / Hermes / Athena
   │
   ├── kubectl → Hermes K3s
   │
   └── Git → application/configuration repositories
```

This keeps administration separate from the servers themselves.

---

# 19. Olympus Dashboard

**Olympus** is the custom infrastructure dashboard/control-plane visibility layer.

Its purpose is **not to replace Grafana**.

Grafana remains responsible for detailed telemetry and monitoring.

Olympus is intended to provide a higher-level view of the infrastructure.

Its architecture is designed around server-side access to existing infrastructure APIs rather than exposing sensitive infrastructure interfaces directly to the browser.

Relevant integrations include:

```text
Olympus
├── Proxmox
├── Prometheus
├── Loki
└── Kubernetes
```

The intended deployment target is Hermes K3s.

The dashboard should remain a relatively lightweight infrastructure overview rather than becoming another full observability platform.

---

# 20. Directory Organization

Hermes currently follows a separation between applications, Kubernetes configuration, backups, system configuration, and temporary files.

```text
~/apps/
├── dashboard/
└── floci/
    ├── compose/
    ├── compose.yml
    └── data/

~/backups/

~/config/

~/k8s/
├── apps/
├── infrastructure/
└── namespaces/

~/scripts/
├── start
└── stop

~/tmp/
```

This provides a clear distinction between:

```text
apps/     → application workloads
k8s/      → Kubernetes manifests/configuration
config/   → host configuration
scripts/  → operational scripts
backups/  → backup storage
tmp/      → temporary work
```

---

# 21. Kubernetes Configuration Structure

The Kubernetes configuration on Hermes is organized under:

```text
~/k8s/
├── apps/
├── infrastructure/
└── namespaces/
```

This separates application manifests from cluster/infrastructure configuration and namespace definitions.

K3s is currently a single-node learning and application platform rather than a production HA cluster.

---

# 22. Docker vs Kubernetes Strategy

The homelab intentionally uses both Docker Compose and Kubernetes.

### Docker Compose

Used where a workload is intentionally maintained as a Compose application.

Current example:

```text
Floci → Docker Compose
```

### Kubernetes

Used for:

* learning Kubernetes
* deploying Kubernetes-native applications
* practicing deployments
* services
* ingress
* configuration
* secrets
* persistent workloads

Current example:

```text
Hermes → K3s
```

The goal is not to migrate every existing Docker workload into Kubernetes simply for the sake of migration.

---

# 23. Storage

Apollo provides the underlying VM storage.

Current Proxmox storage includes:

```text
local
local-lvm
Storage
```

The large `Storage` filesystem is mounted at:

```text
/mnt/pve/Storage
```

The Athena migration backup was temporarily stored there during the VM migration and has now been removed.

The old Athena VM's disk was also removed when VM 100 was destroyed.

---

# 24. Athena Migration

The previous Athena environment was migrated from:

```text
VM 100
Ubuntu 20.04
```

to:

```text
VM 102
Ubuntu 24.04
```

The migration preserved:

* Prometheus data
* Grafana data
* Loki data
* telemetry configuration

The restored observability data was verified after migration.

The new Athena was then tested for:

* Prometheus health
* Loki health
* Grafana health
* cAdvisor
* Prometheus scrape targets
* Hermes → Loki connectivity

After successful verification, the old VM 100 was permanently deleted.

The migration backups were subsequently removed as well.

Therefore, **VM 102 is now the only Athena instance**.

---

# 25. Current State

The current homelab can be summarized as:

```text
                         ARTEMIS
                    Management Client
                         │
                    SSH / kubectl
                         │
                         ▼
                  ┌───────────────┐
                  │    APOLLO     │
                  │   Proxmox VE  │
                  │               │
                  │ 10.10.10.1    │
                  └───────┬───────┘
                          │
             ┌────────────┴────────────┐
             │                         │
             ▼                         ▼
      ┌──────────────┐         ┌──────────────┐
      │    HERMES    │         │    ATHENA    │
      │    VM 101    │         │    VM 102    │
      │              │         │              │
      │ K3s          │         │ Prometheus   │
      │ Traefik      │         │ Grafana      │
      │              │         │ Loki         │
      │ Floci        │         │ Alloy        │
      │ Docker       │         │ Node Exporter│
      │              │         │ cAdvisor     │
      │ cAdvisor     │         │ PVE Exporter │
      │ Alloy        │────────►│ Glances      │
      │              │  Loki   │              │
      └──────────────┘         └──────────────┘
             │
             │
             ▼
        Applications
```

---

# 26. Design Principles

The current homelab follows several deliberate principles.

### Separation of concerns

```text
Apollo  → infrastructure
Hermes  → applications / Kubernetes
Athena  → observability
Artemis → administration
```

### Centralized observability

Applications and infrastructure expose telemetry to Athena rather than each maintaining its own monitoring stack.

### Kubernetes as the application platform

K3s is the main environment for learning and deploying Kubernetes workloads.

### Docker remains available

Docker Compose remains valid for applications such as Floci where Kubernetes migration is not currently intended.

### Private infrastructure access

Infrastructure interfaces should not be unnecessarily exposed through public Docker ports or direct browser-side infrastructure APIs.

### Tailscale for private connectivity

Tailscale provides a private management and telemetry path between the systems.

### No unnecessary duplication

Grafana is the detailed observability platform. Olympus is intended to provide a higher-level infrastructure overview rather than duplicating Grafana.

---

# 27. Current Roadmap

The environment is currently at the point where the infrastructure and observability foundation are established.

### Completed

* Apollo Proxmox infrastructure
* Hermes VM
* Athena replacement VM
* Docker on Hermes
* Docker on Athena
* K3s single-node cluster
* Traefik
* Floci deployment
* Prometheus
* Grafana
* Loki
* Alloy
* Node Exporter
* cAdvisor
* Proxmox exporter
* Glances
* Hermes → Athena centralized logging
* Prometheus → Hermes monitoring
* Proxmox monitoring
* Athena migration
* Old Athena retirement

### Current focus

**Kubernetes application deployment on Hermes.**

The next stage is to move from a K3s cluster that is primarily being learned and tested into a cluster hosting a real application workload.

Olympus is a natural candidate for this stage.

### Later

* Additional Kubernetes node(s)
* Multi-node K3s
* Oracle as a worker node when available
* More real applications
* D2Bus deployment
* Further Kubernetes networking/storage practice

---

## One-line architecture summary

> **Apollo provides the Proxmox infrastructure; Hermes is the K3s and application platform; Athena provides centralized metrics, logs, and observability; Artemis is the management workstation; Tailscale provides private connectivity between the systems; and Olympus provides a lightweight infrastructure-level view without replacing Grafana.**
