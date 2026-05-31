# HomeLab

Lean homelab roadmap and operating notes for building a small, remotely manageable home server stack before college.

## Goal

The target outcome is a headless home server that can be managed remotely over Tailscale, with a dashboard, monitoring, alerting, local AWS-style experimentation, Terraform-managed infrastructure, Git-tracked configuration, and tested backup and recovery procedures.

Success means the full environment can be administered from a laptop without needing direct physical access.

## Roadmap

The plan is organized into four phases:

1. Preparation
	- Back up existing data
	- Create the repository and documentation structure
	- Download required software
2. Infrastructure Foundation
	- Install Proxmox VE
	- Configure networking
	- Create an Ubuntu Server VM
	- Install Docker and Tailscale
	- Set up backups
3. Visibility and Operations
	- Deploy Homepage, Portainer, Prometheus, Grafana, and optional personal services
4. Cloud, Automation, and Reliability
	- Add LocalStack and Terraform
	- Push configuration to Git
	- Add Loki, alerts, and recovery drills

See [HOMELAB_ROADMAP.md](HOMELAB_ROADMAP.md) for the full 30-day checklist.

## Planned Repository Layout

```text
homelab/
├── README.md
├── HOMELAB_ROADMAP.md
├── docs/
│   ├── architecture.md
│   ├── network.md
│   └── troubleshooting.md
├── docker-compose/
├── terraform/
├── scripts/
└── screenshots/
```

## Core Milestones

- Proxmox running on the host machine
- Ubuntu Server VM autostarting at boot
- Docker and Docker Compose installed inside the VM
- Tailscale enabling remote access
- Homepage, Portainer, Prometheus, Grafana, and Loki available
- LocalStack and Terraform used for local cloud experiments
- Backups and recovery procedures verified

## Documentation To Keep Updated

- `docs/architecture.md` for system layout and service relationships
- `docs/network.md` for IP addresses, router settings, and remote access notes
- `docs/troubleshooting.md` for known issues and recovery steps

## Validation Checklist

- Proxmox web UI is reachable
- Docker test container runs successfully
- Tailscale access works from the laptop
- Backups are generated and restorable
- Monitoring dashboards show live data
- Recovery drills are documented and repeatable

## Expected Skills Gained

- Linux administration
- Virtualization with Proxmox
- Networking and VPN usage
- Docker and containers
- Infrastructure as code with Terraform
- Monitoring and logging
- Backup and recovery
- Documentation discipline
