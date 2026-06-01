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

# 📓 Day 10: Deploy Monitoring Stack (Prometheus & Node Exporter)

## 🎯 Objective

Deploy Prometheus and Node Exporter to establish metric collection and system telemetry. This allows deep kernel monitoring and historical data retention for the Ubuntu VM.

## 🛠️ Infrastructure Achievements

1. **Declarative Monitoring Architecture:** Created `docker-compose/monitoring/` structure on the Arch laptop, maintaining modular separation of concerns.
2. **Prometheus Time-Series Database:** Configured Prometheus with a 15-second scrape interval to collect metrics from both itself and Node Exporter.
3. **Host Telemetry Agent:** Deployed Node Exporter to expose kernel-level metrics (CPU, memory, disk, network) to Prometheus.
4. **Data Persistence:** Provisioned a named `prometheus_data` volume to ensure metrics survive container restart or recreation.
5. **Source-First Development:** Used SCP workflow to push testing-proven configs from Arch laptop to the VM, maintaining git history as the single source of truth.

## 📝 Configuration Files

### `prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

### `docker-compose.yml`

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    ports:
      - 9090:9090

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
    ports:
      - 9100:9100

volumes:
  prometheus_data:
```

## 🔄 Deployment Workflow

### Step 1: Create Directory Structure on Arch Laptop

```bash
mkdir -p docker-compose/monitoring/prometheus
```

### Step 2: Write Configuration Files Locally

Created `docker-compose/monitoring/prometheus/prometheus.yml` and `docker-compose/monitoring/docker-compose.yml` with standard Prometheus scrape config and Node Exporter integration.

### Step 3: Commit to Git on Arch Laptop

```bash
git add docker-compose/monitoring/
git commit -m "feat: design declarative prometheus and node-exporter monitoring stack layout"
```

### Step 4: Push to Ubuntu VM via SCP

```bash
scp -r docker-compose/monitoring/ ubuntu@100.117.35.70:~/homelab/docker-compose/
```

Both `prometheus.yml` and `docker-compose.yml` transferred successfully.

### Step 5: Launch on Ubuntu VM

SSH into the VM and started the stack:

```bash
ssh ubuntu@100.117.35.70
cd ~/homelab/docker-compose/monitoring
docker compose up -d
```

## ✅ Validation Test

Access Prometheus web UI from browser:

```text
http://100.117.35.70:9090
```

Navigate to **Status** → **Targets** and verify:

- `prometheus` job shows green `UP` status
- `node-exporter` job shows green `UP` status

Both endpoints collecting metrics successfully. **Status: LIVE ✅**

## 🔗 Integration with Homepage Dashboard

Updated `docker-compose/homepage/config/services.yaml` to add Prometheus as an infrastructure card:

```yaml
    - Prometheus:
        icon: prometheus
        href: "http://100.117.35.70:9090"
        description: "Time-Series Telemetry DB"
```

Workflow:
1. Updated services.yaml locally on Arch laptop
2. Committed to git
3. Pushed to VM via SCP: `scp docker-compose/homepage/config/services.yaml ubuntu@100.117.35.70:~/homelab/docker-compose/homepage/config/`
4. Restarted Homepage on VM: `cd ~/homelab/docker-compose/homepage && docker compose down && docker compose up -d`
5. Hard-refreshed browser (`Ctrl` + `Shift` + `R`) to see new Prometheus card on dashboard

Prometheus now accessible directly from the Homepage dashboard.

---

## 💥 Technical Challenges & Resolution Index (Day 10 Deployment)

### 1. High-Velocity Database Commits Avoidance

**Problem:** Databases generated by tracking systems run on a high-frequency write pattern, outputting unique binary chunks every single second. Attempting to manage these files inside Git results in immediate repository corruption and failed commits.

**Root Cause:** Prometheus handles data utilizing custom-built Time-Series Database (TSDB) logs. Git is built to compute variations on sequential plaintext strings, not write-heavy binary blobs.

**Resolution:** Constructed a systematic `.gitignore` matrix applying a wildcard target (`**/prometheus_data/`) across the root of the project structure. This enables configuration tracking while isolating high-frequency data states.

---

## 📍 Final Day 10 Architectural Layout

```text
       [ Arch Laptop (artemis) ]  ─── Master Git Repository
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
      │   ├── Homepage (Port3000)│ ✅
      │   ├── Portainer(Port9443)│ ✅
      │   ├── Prometheus(Port9090)│ ✅ LIVE & COLLECTING METRICS
      │   └── Node-Exp (Port9100)│ ✅
      └──────────────────────────┘
           
    ⬇️ All configs tracked in:
      ~/homelab/docker-compose/
      ─── homepage/
      ─── portainer/
      ─── monitoring/

```

---

## 🎓 Key Accomplishments This Week

- **Week 1 Complete:** Built a resilient, headless Proxmox + Ubuntu Docker host with Tailscale remote access
- **Week 2 Progress:** Deployed Homepage, Portainer, and a full Prometheus + Node Exporter monitoring stack
- **Source Control Mastery:** Established a "Arch-First" Git workflow; all infrastructure configs authored locally, committed, and synced to production for deployment
- **Zero Downtime Architecture:** Every service is running and reporting healthy metrics in real time over Tailscale

---

## ⏭️ Ready for Day 11: Deploy Grafana

When you're ready to visualize these metrics with professional dashboards and alerting rules, let me know and we'll wire Prometheus data into Grafana.

---

# 📓 Day 11: Deploy Grafana Visualization

## 🎯 Objective

Complete the operational monitoring matrix by deploying Grafana Open Source (OSS), establishing intra-container networking links with Prometheus, and importing system hardware visualization templates.

## 🛠️ Infrastructure Achievements

1. **Multi-Service Compose Expansion:** Appended Grafana to the centralized `monitoring/docker-compose.yml` deployment script, optimizing resource reuse via an abstract system data storage volume configuration (`grafana_data`).
2. **Network Collision Avoidance Mitigation:** Configured port forwarding architecture to map internal container port `3000` to public interface port `3001` (`3001:3000`), completely bypassing port-binding conflicts with the existing Homepage gateway container running on host port `3000`.
3. **Internal Container DNS Mesh Mapping:** Wired Grafana's database engine directly to the upstream storage array utilizing the automated internal bridge network alias resolution (`http://prometheus:9090`), avoiding hardcoded static IP overhead.

## 💥 Technical Challenges & Resolution Index

### 1. Host Port Binding Conflict (`Port Already Allocated`)

**Problem:** Attempting to assign Grafana to its default production image configuration parameters caused a network bind error during launch steps.

**Root Cause:** Grafana uses port `3000` inside its core compilation rules. However, the Homepage Dashboard service was already actively listening on host interface port `3000` via the Ubuntu loopback interface. Two independent host daemons cannot open listening handles on the exact same port vector simultaneously.

**Resolution:** Adjusted the declarative docker translation matrix within the configuration layers to explicitly pass an offset interface map (`3001:3000`). This keeps Grafana listening cleanly on port `3000` inside its isolated container space while routing inbound internet traffic from Tailscale requests gracefully on port `3001`.

---

## 📍 Updated Architectural Layout

```text
   [ Arch Laptop (artemis) ]
       │
     🔒 Secure Tailscale Mesh
       │
  ┌────────────┴─────────────┐
  │  Proxmox Server (apollo) │
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
  │   ├── Portainer(Port9443)│
  │   ├── Prometheus(Port9090)│ <--- LIVE
  │   └── Node-Exporter(9100)│ <--- LIVE
  └──────────────────────────┘

```

---

# 📓 Homelab Engineering Log: Day 12 — Relabeled Proxmox Telemetry Integration

## 🎯 Objective

To complete bare-metal host monitoring by routing Proxmox VE hypervisor metrics natively into Prometheus and Grafana without exposing plaintext core administrative credentials within the codebase.

---

## 🛠️ Infrastructure Achievements & Configuration

1. **Dynamic Parameter Relabeling Topology:** Configured a complex `relabel_configs` orchestration sequence within `prometheus.yml`. This abstracts the connection flow, masking the proxy container destination (`proxmox-exporter:9221`) while seamlessly passing the target physical endpoint variable (`10.10.10.1`).
2. **API Endpoint Translation Layer:** Deployed the official `prompve/prometheus-pve-exporter` container image, mounting a secure local configuration asset (`pve.yml`) read-only (`ro`) to execute secure query loops against the hypervisor cluster interface.
3. **Multi-Tier Visual Aggregation:** Imported Grafana Matrix Asset ID `10347` to tie host hardware metrics and virtual allocation layers into a singular, cohesive operational pane.

---

## 💥 Technical Challenges & Resolution Index

### 1. Inbound Target Scrape 500 Execution Errors

- **The Problem:** The initial connection bridge between Prometheus and the exporter threw a hard `HTTP 500 Internal Server Error`.
- **The Root Cause:** The Prometheus scrape worker was triggering direct calls to the root scraper endpoint without supplying a target query parameter header, causing the backend exporter container to crash because it didn't know which physical node to parse.
- **The Resolution:** Rewrote the job configuration layout on the Arch laptop to implement an advanced URL parameter rewriting block. This forces Prometheus to append the node target string to its queries before routing them through the Docker container network link, restoring clean telemetry data flow.

---
3