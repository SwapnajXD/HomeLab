# Architecture

## Overview

This directory contains architecture diagrams describing the homelab infrastructure.

The homelab is built around a Proxmox VE hypervisor hosting isolated virtual machines and containers for operations, monitoring, development, and self-hosted services.

---

## Infrastructure Components

### Apollo

Role:

```text
Proxmox VE Hypervisor
```

Responsibilities:

* Virtualization
* Storage Management
* Network Management
* VM Hosting
* LXC Hosting

---

### Hestia

Type:

```text
LXC Container
```

Services:

* Homepage Dashboard
* Vaultwarden

Purpose:

Provides user-facing applications and lightweight services.

---

### Athena

Type:

```text
Ubuntu Virtual Machine
```

Services:

* Grafana
* Prometheus
* Loki
* Promtail
* Portainer
* LocalStack

Purpose:

Provides monitoring, observability, container management, and cloud emulation services.

---

### Artemis

Type:

```text
Arch Linux Laptop
```

Purpose:

Primary management workstation used for:

* Infrastructure administration
* Terraform deployments
* Git operations
* Remote management through Tailscale

---

## Network Architecture

```text
Artemis
    │
Tailscale
    │
Apollo
    │
 ┌──┴──┐
 │     │
Hestia Athena
```

---

## Diagram

See:

```text
architecture-diagram.mmd
```

for the complete Mermaid architecture diagram.

