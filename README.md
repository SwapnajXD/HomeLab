# HomeLab

Lean homelab project for building a remotely manageable home server stack before college.

## Goal

Build a headless home server that can be managed remotely over Tailscale, with a dashboard, monitoring, backups, and Terraform-managed infrastructure.

The full plan lives in [HOMELAB_ROADMAP.md](HOMELAB_ROADMAP.md).

## What This Repo Contains

This repository is used to track the homelab plan, supporting documentation, and infrastructure code.

## Planned Structure

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

## Key Areas

- Infrastructure: Proxmox, Ubuntu Server VM, Docker, and Tailscale
- Operations: Homepage, Portainer, Prometheus, Grafana, and Loki
- Automation: LocalStack and Terraform
- Reliability: backups, recovery drills, and documentation

## Documentation

Keep these files updated as the setup grows:

- `docs/architecture.md`
- `docs/network.md`
- `docs/troubleshooting.md`

## Start Here

Read [HOMELAB_ROADMAP.md](HOMELAB_ROADMAP.md) for the detailed 30-day plan and checklist.
