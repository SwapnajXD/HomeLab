# HomeLab

This is my homelab project. I’m building a small home server setup that I can manage remotely before i go back to college.

## Goal

My goal is to set up a headless home server I can reach through Tailscale, with a dashboard, monitoring, backups, and Terraform-managed infrastructure.

The full plan is in [HOMELAB_ROADMAP.md](HOMELAB_ROADMAP.md).

## What I’m Keeping Here

I’m using this repo to keep my plan, notes, and infrastructure files in one place.

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

I’ll keep these files updated as the setup grows:

- `docs/architecture.md`
- `docs/network.md`
- `docs/troubleshooting.md`

## Start Here

Read [HOMELAB_ROADMAP.md](HOMELAB_ROADMAP.md) for the full 30-day plan and checklist.
