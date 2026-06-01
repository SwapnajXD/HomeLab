# Homepage Dashboard

## Purpose

This page documents the first visibility layer in the homelab: a Homepage dashboard running in Docker Compose on the Ubuntu VM.

## Goal

Use Homepage as a central landing page for the homelab so I can quickly jump to Proxmox and the Ubuntu server from a single web UI.

## Directory Layout

Create the dashboard files inside the repository like this:

```text
homelab/
└── docker-compose/
    └── homepage/
        ├── docker-compose.yml
        └── config/
            ├── services.yaml
            └── settings.yaml
```

## Configuration Files

### `config/services.yaml`

```yaml
---
# Infrastructure Group
- Infrastructure:
    - Proxmox:
        icon: proxmox
        href: https://100.81.86.51:8006
        description: Type-1 Hypervisor Host
    - Ubuntu Server:
        icon: ubuntu
        href: http://10.10.10.10
        description: Core Development VM
```

### `config/settings.yaml`

```yaml
---
title: Apollo Operations Dashboard
base: http://localhost:3000
```

### `docker-compose.yml`

```yaml
version: '3.8'

services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    ports:
      - 3000:3000
    volumes:
      - ./config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
```

## Setup Steps

1. Create the folder structure under `~/homelab/docker-compose/homepage`.
2. Create `config/services.yaml` and `config/settings.yaml`.
3. Create `docker-compose.yml` in the homepage directory.
4. Start the service with `docker compose up -d`.
5. Open the dashboard in a browser at `http://YOUR_UBUNTU_VM_TAILSCALE_IP:3000`.

## Validation

- The Homepage container starts cleanly.
- Port `3000` is reachable from the Arch laptop over Tailscale.
- Proxmox and Ubuntu Server links appear on the dashboard.
- Docker socket access allows Homepage to read container status later.

## Notes

- Keep the dashboard config in Git so the setup is reproducible.
- If the Tailscale IP changes, update the service links here too.
- Add more services to `services.yaml` as the stack grows.
