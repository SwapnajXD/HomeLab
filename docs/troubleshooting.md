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

# 📓 Homelab Engineering Log: Day 13 — Homepage Asset Hardening and Vaultwarden Launch

## 🎯 Objective

To turn the homelab into a more complete private services environment by keeping the Homepage dashboard stable without external asset dependencies and deploying Vaultwarden behind private HTTPS on the Tailscale mesh.

---

## 🛠️ Infrastructure Achievements & Configuration

1. **Local-First Dashboard Assets:** Kept the Homepage dashboard lightweight by avoiding external icon/CDN dependencies and relying on locally stored config so the dashboard remains stable in an isolated network.
2. **Private Credential Vault:** Deployed Vaultwarden as the low-footprint credential and notes service for passwords, 2FA, and secure storage.
3. **Encrypted Access Layer:** Bound Vaultwarden to private HTTPS over the Tailscale domain so the browser sees a secure context and can enable the login flow.
4. **Access Control Lifecycle:** Temporarily enabled signups only long enough to create the initial account, then disabled signups again to lock the vault down.

---

## 💥 Technical Challenges & Resolution Index

### 1. 403 Forbidden Icon Loop

- **The Problem:** Homepage attempted to pull application icons from external CDNs, which repeatedly failed with forbidden responses in the isolated homelab network.
- **The Root Cause:** The environment had limited or blocked external asset access, so remote icon fetching was not reliable.
- **The Resolution:** Moved the dashboard to a local-first configuration and backed the working files up to the Arch laptop repository so the dashboard no longer depends on brittle external asset fetches.

### 2. Opaque Response Blocking (ORB)

- **The Problem:** Switching to external asset URLs triggered browser ORB protection and produced HTTP 400-style loading failures.
- **The Root Cause:** The browser refused to load cross-origin assets from insecure local contexts while serving the dashboard from `http://100.117.35.70:3000`.
- **The Resolution:** Avoided cross-origin asset loading for the dashboard and kept the operational configuration local and self-contained.

### 3. Crypto Lockout on Vaultwarden

- **The Problem:** Vaultwarden login and registration pages would not function over a raw IP because the browser required a secure context to enable cryptographic features.
- **The Root Cause:** Modern browsers disable `SubtleCrypto` and related auth functions unless the site is served over HTTPS.
- **The Resolution:** Used a self-signed local certificate strategy on the host machine and bound Vaultwarden to the private Tailscale domain over HTTPS.

### 4. Tailscale Certificate Generation Error

- **The Problem:** The built-in Tailscale certificate path returned a 500-style internal error.
- **The Root Cause:** The tailnet configuration prevented the `tailscale cert` automation from completing.
- **The Resolution:** Fell back to a direct `openssl` certificate workflow on the host, then wired the container to serve HTTPS from that local cert.

### 5. SSL Parsing Panic (`SSL_ERROR_RX_RECORD_TOO_LONG`)

- **The Problem:** The browser failed to connect after local certificates were introduced.
- **The Root Cause:** The container was answering plain HTTP on the port the browser expected to be HTTPS.
- **The Resolution:** Refactored the `docker-compose.yml` so Vaultwarden binds to port `443` using `ROCKET_PORT`, ensuring the browser and container speak the same protocol.

### 6. Signup Paradox

- **The Problem:** Keeping `SIGNUPS_ALLOWED=false` from the start prevented creation of the first master account.
- **The Root Cause:** The vault needed one initial owner account before signups were disabled.
- **The Resolution:** Temporarily enabled signups, created the master account, and then immediately turned signups back off.

### 7. Import Layout Conflict

- **The Problem:** Existing credentials were in spreadsheet form rather than a native vault schema.
- **The Root Cause:** The source data was stored as a standard spreadsheet export instead of a dedicated password-manager format.
- **The Resolution:** Used Vaultwarden's CSV import path to load the spreadsheet records without re-entering them manually.

---

## 📊 Current System State Matrix

| Container / Engine | Status | Access Endpoint | Port Mapping | Resource Profile | Security Mode |
| --- | --- | --- | --- | --- | --- |
| **Homepage** | 🟢 Active | `http://100.117.35.70:3000` | `3000:3000` | Minimal | Tailscale Network Auth |
| **Vaultwarden** | 🟢 Active | `https://ubuntu-dev.taila5af45.ts.net:8080` | `8080:443` | ~50MB RAM | Enforced TLS (Self-Signed) + Signups Disabled |

All core configurations are now tracked in the local Git repository on the Arch laptop, and the homelab runway is clear for the next infrastructure layer.

---

# 📓 Day 23: Infrastructure Optimization & Service Consolidation Refactor

## 🎯 Objective & Executive Summary

Audit and refactor the deployment environment on **athena** (Ubuntu VM) to resolve implicit configuration drift and container management overhead. Consolidate fragmented, standalone multi-directory deployments into a single unified execution domain (`core-services`), minimizing network namespace overhead, reclaiming memory capacity, and bringing production states into absolute alignment with local version-controlled Git repositories on **artemis**.

---

## 🛠️ Infrastructure Changes (What We Did)

### 1. SSH Optimization

Implemented a standardized local SSH configuration matrix (`~/.ssh/config`) on artemis to short-circuit manual IP/username lookups, enabling abstract alias routing:

```bash
ssh athena

```

No need to track full IP addresses or remember usernames—just use the alias.

### 2. Service Consolidation: Docker Compose Unification

**Before:** Separate standalone `docker-compose.yml` environments scattered across:
- `~/homelab/docker-compose/portainer/`
- `~/homelab/docker-compose/vaultwarden/`
- `~/homelab/docker-compose/homepage/`
- `~/homelab/docker-compose/monitoring/`

**After:** Merged all services into a single, master composition stack:
```
~/homelab/core-services/docker-compose.yml
├── Portainer (Admin Console)
├── Vaultwarden (Credentials Vault)
├── Homepage (Dashboard)
├── Prometheus (Metrics)
├── Node Exporter (System Telemetry)
└── Grafana (Visualization)

```

**Impact:** Reduced container orchestration complexity, unified networking namespace, consolidated volume management.

### 3. Resource Sandboxing: LocalStack Manual Invocation

Extracted LocalStack away from automated system-d or Docker engine boot hooks—moved execution posture to **manual invocation only**:

```yaml
localstack:
  image: localstack/localstack:4.4.0
  restart: "no"  # Never auto-start; prevents memory bloat
  # ... rest of config ...

```

**Impact:** LocalStack no longer consumes host memory at boot; enables on-demand sandboxing for Terraform IaC testing.

---

## 💥 Engineering Challenges & Troubleshooting (How We Solved It)

### Challenge 1: Permission Denied Errors on Directory Cleandown

**The Symptom:**
```bash
$ rm -rf ~/homelab/docker-compose/
rm: cannot remove '...': Permission denied
rm: cannot remove database.sqlite3: Operation not permitted

```

**The Root Cause:** The master `core-services/docker-compose.yml` file was mapped directly to active data directories inside the legacy paths via absolute links. Because the containers were actively running, the Docker engine held kernel-level locks on SQLite databases and cache structures under root privileges. Forced system deletion would have caused instantaneous database corruption and catastrophic password data loss (Vaultwarden vault).

**The Resolution:**
1. Gracefully brought down the running composition stack to release engine file locks:
```bash
cd ~/homelab/core-services && docker compose down

```
2. Executed file migrations (`mv`) to pull the production database (`vaultwarden-data`) and configurations (`homepage-config/`) locally into the active relative path workspace:
```bash
mv ~/homelab/docker-compose/vaultwarden/vaultwarden-data ~/homelab/core-services/
mv ~/homelab/docker-compose/homepage/config ~/homelab/core-services/homepage-config/

```
3. Relinked the volume mounts within the master composition file using self-contained relative path mapping nodes (`./vaultwarden-data` instead of absolute paths).

---

### Challenge 2: Total Application Reset / Empty States on Initial Boot

**The Symptom:**
- **Portainer:** Initialized into an unconfigured state demanding fresh administrative user creation.
- **Homepage:** Displayed default generic sample placeholders instead of custom infrastructure tiles.

**The Root Cause:**
1. **Portainer:** Moving directory scopes shifted Docker's implicit named volume prefix mapping from `docker-compose_portainer_data` to a blank volume instance (`core-services_portainer_data`).
2. **Homepage:** The original data configurations inside the legacy folders had generic, commented-out template variables and a disabled underlying Docker API runtime socket (`docker.yaml` was not configured).

**The Resolution:**
1. Swapped the generic Homepage example code block inside `services.yaml` with an explicit, structured layout split cleanly into logical columns representing specific hardware layers (Proxmox, Monitoring, Docker, Utilities).
2. Stripped comment headers (`#`) out of `docker.yaml` to unlock native engine communication via `/var/run/docker.sock`:
```yaml
# docker.yaml - BEFORE (commented/disabled)
# docker:
#   host: http://localhost:2375

# docker.yaml - AFTER (active)
docker:
  host: unix:///var/run/docker.sock

```
3. Decided to keep the fresh, isolated **Portainer instance clean** while letting its internal daemon automatically auto-discover the running monitoring stack over the system socket bridge (no manual endpoint configuration needed).

---

## ✅ Current System State (Post-Day 23 Refactor)

| Service | Status | Access | Port | Mode | Notes |
| --- | --- | --- | --- | --- | --- |
| **Homepage** | 🟢 UP | `http://100.117.35.70:3000` | `3000:3000` | Active | Auto-discovers Docker containers via socket |
| **Portainer** | 🟢 UP | `https://100.117.35.70:9443` | `9443:9443` | Active | Fresh instance, auto-discovering services |
| **Vaultwarden** | 🟢 UP | `https://athena.ts.net:443` | `8080:443` | Active | Vault locked, manual signups only |
| **Prometheus** | 🟢 UP | `http://100.117.35.70:9090` | `9090:9090` | Active | Scraping node-exporter, PVE exporter |
| **Grafana** | 🟢 UP | `http://100.117.35.70:3001` | `3001:3000` | Active | Visualizing metrics, hardware dashboards |
| **Node Exporter** | 🟢 UP | `:9100` | `9100:9100` | Active | System telemetry collection |
| **LocalStack** | 🟡 Manual | `http://100.117.35.70:4566` | `4566:4566` | Off (on-demand) | Restart: "no" - manual invocation only |

All configurations are unified in `~/homelab/core-services/` and fully version-controlled on artemis Git repository. Production state now perfectly mirrors the Git tracking tree.
