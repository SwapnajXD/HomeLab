# Troubleshooting

## Purpose

Use this file for repeatable recovery steps, common failures, and checks that help restore the homelab quickly.

## Planned Sections

- Boot and startup issues
- Docker and container failures
- Tailscale connectivity problems
- Backup and recovery steps
- Monitoring and alerting issues

## Notes

Add symptoms, root causes, and the exact fix after each incident.

## Recent Incident Report

- [Homelab Post-Mortem - 2026-06-01](homelab-postmortem-2026-06-01.md)

---

# 📓 Homelab Engineering Log & Architecture Review

## 🛠️ Phase 1: Core Infrastructure Achievements

By completing the foundational stage of the roadmap, I transitioned the physical machine (`apollo`) from a standard desktop OS into an isolated, multi-layered server mesh:

1. **Bare-Metal Virtualization:** Deployed Proxmox VE as a Type-1 Hypervisor.
2. **Headless Linux Compute Engine:** Built an Ubuntu Server VM (`ubuntu-dev-box`) mapped with full storage allocations.
3. **Container Pipeline Integration:** Installed Docker Engine and Docker Compose inside the guest OS.
4. **Zero-Trust Remote Connectivity:** Configured Tailscale across both the Proxmox host and the Ubuntu VM so I can SSH and access web UIs from my Arch laptop (`artemis`) without opening router ports.
5. **Declarative Operations Control:** Deployed the Homepage Dashboard container as a single landing page for local resources.
6. **Immutable Automated Checkpoints:** Configured VZDump snapshot automation to back up VM images to the host storage.

## 💥 Technical Challenges & Resolution Index

### 1. The LVM Root Storage Partition Cap

The Ubuntu Server installer initially left much of the virtual disk unassigned, which would have quickly caused "disk full" issues when pulling container images.

**Root Cause:** LVM defaults leave free space for manual adjustments.

**Resolution:** During installation I removed the restrictive cap and expanded `ubuntu-lv` to use the full available disk (~29.996G).

---

### 2. The Physical Wi-Fi Bridge Isolation Block

When applying a static IP inside the VM, outbound packets failed and SSH connections could not be established.

**Root Cause:** The Proxmox host is on Wi‑Fi; wireless APs reject arbitrary virtual MACs that haven't authenticated, so a standard bridge (`vmbr0`) doesn't work over Wi‑Fi.

**Resolution:** Converted `vmbr0` into an internal NAT/maskerade layer (`10.10.10.1/24`) and added an iptables POSTROUTING MASQUERADE rule on the host, for example:

```bash
post-up iptables -t nat -A POSTROUTING -s '10.10.10.0/24' -o wlx002e2df0393b -j MASQUERADE
```

This lets the host translate VM traffic so it appears to come from the host's authenticated Wi‑Fi adapter.

---

### 3. Virtual Cable Disconnection Hang

After switching the VM to the NAT gateway, the VM hung at "A start job is running for Wait for Network to be Configured" on boot.

**Root Cause:** The VM's virtual NIC had the Proxmox "Disconnect" safety checkbox enabled.

**Resolution:** In the Proxmox Hardware GUI I unchecked "Disconnect" on `net0` (virtually plugging the Ethernet cable back in), allowing the VM to bring up networking immediately.

---

### 4. Convenience Script Deprecation Intercept

The `get.docker.com` convenience script refused to run on the older Ubuntu LTS release.

**Root Cause:** The convenience script blocks execution on unsupported distro versions to avoid dependency issues.

**Resolution:** Installed Docker via the official APT repository: add Docker's GPG key, create `/etc/apt/sources.list.d/docker.list`, then:

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
```

---

### 5. Dashboard Host Validation Block

Accessing the Homepage on port 3000 initially produced a "Host validation failed" error because requests came from the Tailscale IP rather than a local LAN origin.

**Root Cause:** The app's host validation blocked requests from the Tailscale hostname.

**Resolution:** Added a permissive variable to the container environment to allow authenticated Tailnet traffic, for example:

```yaml
environment:
	- HOMEPAGE_ALLOWED_HOSTS=*
```

Then recreated the container with `docker compose up -d --force-recreate`.

---

## 📍 Current Architectural Layout Reference

```text
			 [ Arch Laptop (artemis) ]
									 │
				 🔒 Secure Tailscale Mesh
									 │
			┌────────────┴─────────────┐
			│  Proxmox Server (apollo) │
			│  (Host IP: 192.168.1.150)│
			└────────────┬─────────────┘
									 │
			🔀 Host NAT Gateway (10.10.10.1)
									 │
			┌────────────┴─────────────┐
			│     Ubuntu Server VM     │
			│  (Static IP: 10.10.10.10)│
			├──────────────────────────┤
			│  🐳 Active Docker Core   │
			│   └── Homepage (Port3000)│
			└──────────────────────────┘

```

## Follow-Up

- Update `docs/network.md` with the final NAT and host UI addresses (done).
- Keep this engineering log here for future incident review.
- I haven't added Portainer to docs because it hasn't been installed yet.

---
