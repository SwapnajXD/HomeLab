# HomeLab

![Platform](https://img.shields.io/badge/platform-Proxmox-blue)
![OS](https://img.shields.io/badge/os-Ubuntu-orange)
![Containers](https://img.shields.io/badge/containers-Docker-blue)
![IaC](https://img.shields.io/badge/IaC-Terraform-purple)
![Monitoring](https://img.shields.io/badge/monitoring-Grafana%20%7C%20Prometheus-green)
![Logging](https://img.shields.io/badge/logging-Loki-yellow)
![Alerting](https://img.shields.io/badge/alerting-Telegram-success)
![VPN](https://img.shields.io/badge/network-Tailscale-blue)

A self-hosted homelab built on Proxmox VE for learning infrastructure engineering, observability, networking, automation, Infrastructure as Code, and disaster recovery practices.
The environment is fully manageable remotely through Tailscale and is designed to remain operational without physical access.

---

## Infrastructure Overview
* **Apollo:** Proxmox VE Hypervisor
* **Athena:** Ubuntu VM (Monitoring, Automation, IaC)
* **Hestia:** LXC Container (Core Applications)
* **Artemis:** Arch Linux Management Workstation

---

## Key Achievements
* Built a multi-node Proxmox homelab
* Implemented secure remote management through Tailscale
* Centralized monitoring using Prometheus and Grafana
* Centralized log aggregation using Loki and Grafana Alloy
* Implemented Telegram-based infrastructure alerting
* Automated cloud resource provisioning using Terraform
* Validated infrastructure through reboot and disaster recovery testing
* Maintained complete infrastructure documentation
* Implemented Infrastructure as Code workflows using LocalStack and Terraform
* Performed troubleshooting and root cause analysis on production-style incidents

---

## Technology Stack
### Infrastructure
* Proxmox VE | Ubuntu Server | Linux Containers (LXC) | Docker | Docker Compose
### Networking
* Tailscale | Linux Bridges | Proxmox Virtual Networking
### Monitoring, Logging & Alerting
* Grafana | Prometheus | Loki | Grafana Alloy | Node Exporter | Proxmox Exporter | Telegram Alerting
### Automation & IaC
* Terraform | LocalStack | AWS CLI | Bash

---

## Infrastructure as Code
Terraform is used with LocalStack to simulate AWS services locally.
Current resources include:
* `tf-homelab-storage-bucket`
* `tf-homelab-metadata`

Benefits:
* Repeatable deployments
* Safe experimentation
* No cloud costs
* Infrastructure testing workflows

---

## Documentation Map
| Document | Description |
| ------ | ------ |
| [Architecture](docs/architecture.md) | Infrastructure architecture |
| [Network](docs/network.md) | Network topology and routing |
| [Security](docs/security.md) | Security posture and access controls |
| [Inventory](docs/inventory.md) | Infrastructure inventory |
| [Runbook](docs/runbook.md) | Operational procedures |
| [Troubleshooting](docs/troubleshooting.md) | Issues encountered and resolutions |
| [Disaster Recovery](docs/disaster-recovery.md) | Recovery procedures |
| [Validation Report](docs/validation-report.md) | Validation and testing results |
| [Changelog](docs/changelog.md) | Infrastructure changes over time |
| [Project Timeline](docs/project-timeline.md) | Project milestones and history |
| [Roadmap](HOMELAB_ROADMAP.md) | Lean Engineering Homelab Roadmap |

---

## Screenshots

### Homepage Dashboard
![Homepage Dashboard](screenshots/homepage-dashboard.png)

### Grafana Dashboard
![Grafana Dashboard](screenshots/grafana-dashboard.png)

### Prometheus Targets
![Prometheus Targets](screenshots/prometheus-targets.png)

### Loki Logs
![Loki Logs](screenshots/loki-logs.png)

### Portainer
![Portainer](screenshots/portainer.png)

### Proxmox Summary
![Proxmox Summary](screenshots/proxmox-summary.png)

---

## Future Roadmap & Plans
The following initiatives are planned for the next phase of the homelab's evolution:
* **CI/CD & GitOps:** Transitioning the repository into a fully automated GitOps deployment structure.
* **Backup & Restore Automation:** Scripting automated, version-controlled backups for all container volumes and configurations.
* **ESP32 Telemetry Integration:** Integrating external IoT and hardware sensors into the Prometheus metrics pipeline.
* **Advanced Monitoring Upgrades:** Adding network latency tracking, uptime monitoring, and SRE-grade Grafana dashboards.
* **Security Enhancements:** Implementing Tailscale ACLs, network device tagging, and secure authentication layers for Prometheus and Loki.
* **Architecture Flow Diagrams:** Generating dedicated Mermaid.js flow diagrams for metrics, logging, alerting, and recovery.

---

## License
MIT License