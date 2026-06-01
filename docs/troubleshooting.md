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

---

# 📓 Day 9: Portainer Deployment

## 🎯 Objective

Deploy Portainer Community Edition (CE) using Docker Compose to establish a visual management console over the private network. This lets me control containers, networks, volumes, and images without relying on raw terminal commands.

## 🛠️ Infrastructure Achievements

1. **Declarative Compose Architecture:** Created an isolated directory structure (`~/homelab/docker-compose/portainer/`).
2. **Container Runtime Access:** Mounted `/var/run/docker.sock` into the Portainer container to give it administrative privileges over the Docker daemon.
3. **Data Persistence Engine:** Provisioned a named Docker volume (`portainer_data`) mapped to `/data` so credentials, endpoints, and custom stacks survive container teardowns or server reboots.
4. **Hardened Execution Context:** Injected security flags (`no-new-privileges:true`) to prevent privilege escalation.
5. **Centralized Integration:** Added Portainer to the Homepage Dashboard via `config/services.yaml`.

## 💥 Technical Challenges & Resolution Index

### 1. Browser TLS Untrusted Certificate Warning

**Problem:** Navigating to `https://100.117.35.70:9443` triggered a browser security block stating "Your connection is not private."

**Root Cause:** Portainer uses a self-signed certificate not signed by a public CA like Let's Encrypt.

**Resolution:** This is expected and safe for private homelab environments. I clicked **Advanced** → **Proceed to 100.117.35.70 (unsafe)** to accept the local TLS encryption over the Tailscale tunnel.

---

### 2. Homepage Dashboard Asset Caching Block

**Problem:** After adding Portainer to `config/services.yaml`, a simple `docker compose restart homepage` didn't show the new service card on the dashboard.

**Root Cause:** The Homepage app caches configuration in memory during startup. A simple restart doesn't always force a state flush. Additionally, browsers cache frontend layouts aggressively.

**Resolution:** Completely reset the containers and cleared the browser cache:

```bash
docker compose down
docker compose up -d
```

Then pressed **`Ctrl` + `Shift` + `R`** in the browser to force-refresh and dump local cache storage.

---

## 📍 Updated Architectural Layout

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
      │   ├── Homepage (Port3000)│
      │   └── Portainer(Port9443)│ <--- Added and Verified!
      └──────────────────────────┘

```

---

# 📓 Git Workflow Realignment: Arch Laptop as Master Repository

## 🎯 Objective

Establish a single source of truth for all homelab configurations on the Arch laptop (`artemis`), using SCP to sync runtime files from the Ubuntu VM. This keeps the production server lean and dependency-free while maintaining full version control history on the management workstation.

## 💥 Technical Challenges & Resolution Index

### Problem: Git Overhead on Production VM

Running Git commands natively inside a production VM creates unnecessary workspace drift, config duplicates, and requires managing redundant SSH deployment keys on the server itself.

### Root Cause

Architectural separation of concerns: a server should act purely as a headless compute engine, while the engineer's workstation should act as the administrative development environment.

### Resolution

Realigned the workflow to use **Secure Copy Protocol (SCP)** over the encrypted Tailscale layer. Configurations are authored and committed on the Arch laptop, then synced to the VM for live deployment.

## 🛠️ Sync Workflow

### Step 1: Pull Files from Ubuntu VM to Arch Laptop

Open a terminal **on your Arch laptop** (not in the SSH session). Navigate to your local `HomeLab` repo and sync the docker-compose directories:

```bash
cd /path/to/your/local/HomeLab

# Pull homepage from the VM
scp -r ubuntu@100.117.35.70:~/homelab/docker-compose/homepage docker-compose/

# Pull portainer from the VM
scp -r ubuntu@100.117.35.70:~/homelab/docker-compose/portainer docker-compose/
```

### Step 2: Create `.gitignore` on Your Arch Laptop

Create a `.gitignore` at the root of your local `HomeLab` folder to exclude runtime artifacts:

```bash
nano .gitignore
```

Add these patterns:

```text
# Ignore container log outputs generated on the VM
**/logs/
*.log

# Ignore raw container database volumes
**/prometheus_data/
**/portainer_data/

# Ignore OS system artifacts
.DS_Store
```

Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

### Step 3: Stage and Commit on Your Arch Laptop

Commit the synced files to track your progress:

```bash
# Check the layout
git status

# Stage all new files
git add .

# Commit with a clear message
git commit -m "feat: track homepage and portainer infrastructure configuration files from VM"
```

## 📋 Going Forward

- Author and edit all configs on your Arch laptop in the `HomeLab` repo.
- Use `git commit` and `git push` to track history on your laptop.
- Use `scp` to push updated configs to the Ubuntu VM for deployment.
- The Ubuntu VM runs containers but does not manage Git.

---
