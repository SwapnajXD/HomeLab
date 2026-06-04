# HomeLab

A production-inspired self-hosted infrastructure platform built on Proxmox VE for learning systems administration, virtualization, observability, Infrastructure as Code (IaC), and remote operations.

The environment is designed to operate headlessly from a home network while being fully accessible through a secure Tailscale mesh network.

---

## Infrastructure Overview

```text
Artemis (Arch Linux Laptop)
        │
   Tailscale Mesh
        │
      Apollo
   (Proxmox VE)
        │
 ┌──────┴──────┐
 │             │
Hestia       Athena
 (LXC)      (Ubuntu VM)
```

### Hestia

Services:

* Homepage Dashboard
* Vaultwarden

### Athena

Services:

* Grafana
* Prometheus
* Loki
* Promtail
* Portainer
* LocalStack

### Artemis

Management workstation used for:

* Infrastructure administration
* Terraform deployments
* Git operations
* Remote troubleshooting
* Validation testing

---

## Technologies

### Virtualization

* Proxmox VE
* LXC Containers
* Ubuntu Virtual Machines

### Containers

* Docker
* Docker Compose
* Portainer

### Monitoring & Observability

* Grafana
* Prometheus
* Node Exporter
* Proxmox Exporter
* Loki
* Promtail

### Infrastructure as Code

* Terraform
* LocalStack

### Networking

* Tailscale
* Linux Networking
* Docker Networking

---

## Project Goals

* Build a remotely managed headless infrastructure platform
* Learn virtualization and container orchestration fundamentals
* Implement centralized monitoring and log aggregation
* Practice Infrastructure as Code workflows
* Validate disaster recovery and service restoration procedures
* Maintain operational documentation and runbooks

---

## Repository Structure

```text
HomeLab/
├── architecture/
├── docker-compose/
├── docs/
├── screenshots/
├── scripts/
├── terraform/
├── README.md
└── HOMELAB_ROADMAP.md
```

---

## Documentation

| File                 | Description                              |
| -------------------- | ---------------------------------------- |
| architecture.md      | Infrastructure design and service layout |
| network.md           | Network topology and connectivity        |
| runbook.md           | Operational procedures                   |
| troubleshooting.md   | Incident investigations and resolutions  |
| disaster-recovery.md | Recovery procedures and testing          |
| validation-report.md | Infrastructure validation results        |
| inventory.md         | Asset and service inventory              |
| changelog.md         | Infrastructure change history            |

---

## Validation Completed

* Headless server operation
* VM autostart verification
* Docker service recovery testing
* Tailscale remote management validation
* Centralized logging deployment
* Monitoring stack deployment
* Terraform provisioning through LocalStack
* Infrastructure destruction and recreation testing
* Hypervisor reboot recovery validation

---

## Roadmap

The complete build and validation roadmap is documented in:

```text
HOMELAB_ROADMAP.md
```

---

## Skills Demonstrated

* Linux Administration
* Virtualization
* Docker Operations
* Infrastructure as Code
* Monitoring and Observability
* Incident Response
* Disaster Recovery
* Network Engineering
* Documentation and Runbook Development
* Git-based Infrastructure Management

```
```
