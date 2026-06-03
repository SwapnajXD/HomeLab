# 🚀 Lean Engineering Homelab Roadmap (30-Day Student Edition)

## 🎯 Goal

By the time I leave for college, I will have:

* A headless home server
* Secure remote access through Tailscale
* A centralized dashboard
* Monitoring and alerting
* Local AWS experimentation using LocalStack
* Terraform-managed infrastructure
* Git-tracked configurations
* Tested backup and recovery procedures

**Success Metric:** I can manage my entire home infrastructure remotely from my hostel using only my laptop.

---

# Week 0: Preparation (1–2 Days)

## Backup Existing Data

* Copy important Windows files to:

  * External drive
  * Cloud storage
  * Laptop

### Verification

* Open several files from backup locations
* Confirm backups are usable

---

## Create Repository Structure

```text
homelab/
├── README.md
├── docs/
├── docker-compose/
├── terraform/
├── scripts/
└── screenshots/
```

---

## Create Documentation Files

```text
docs/
├── architecture.md
├── network.md
└── troubleshooting.md
```

---

## Download Required Software

* Proxmox VE ISO
* Ventoy (or preferred USB flashing tool)

---

# Week 1: Infrastructure Foundation

## Day 1 — Install Proxmox VE

### Tasks

* Flash Proxmox VE ISO to USB
* Install Proxmox on desktop
* Verify storage detection
* Verify web interface access

### Validation

* Proxmox web UI accessible
* Storage visible
* System stable

---

## Day 2 — Configure Networking

### Preferred

```text
Router
│
Ethernet
│
Proxmox
```

### Alternative

```text
Router
│
Wi-Fi
│
Proxmox
```

### Documentation

* Record network settings
* Record IP addresses
* Update `docs/network.md`

---

## Day 3 — Create Ubuntu Server VM

### Recommended Configuration

```text
CPU: 4 cores
RAM: 6 GB
Storage: 50–100 GB
```

### Settings

* Enable auto-start at boot

---

## Day 4 — Install Docker

### Tasks

* Install Docker
* Install Docker Compose

### Validation

```bash
docker run hello-world
```

---

## Day 5 — Configure Tailscale

### Tasks

* Install Tailscale inside Ubuntu VM
* Connect laptop and VM to same tailnet

### Validation

* Laptop can access VM remotely
* Tailscale MagicDNS working

---

## Day 6–7 — Configure Backups

### Tasks

* Create scheduled Proxmox VM backup
* Test backup generation

### Documentation

Record:

* Backup location
* Recovery procedure

---

# Week 2: Visibility & Operations

## Day 8 — Deploy Homepage Dashboard

### Tasks

Deploy Homepage using Docker Compose.

### Dashboard Entries

* Proxmox
* Ubuntu VM
* Future services

---

## Day 9 — Deploy Portainer

### Tasks

Deploy Portainer CE.

### Practice

* View logs
* Restart containers
* Create stacks

---

## Day 10 — Deploy Monitoring Stack

### Services

* Prometheus
* Node Exporter

### Validation

* Metrics collected successfully

---

## Day 11 — Deploy Grafana

### Create Dashboards

* CPU usage
* Memory usage
* Disk utilization
* Network traffic

---

## Day 12 — Enhance Homepage

### Add Widgets

* System status
* Container status
* Resource usage

---

## Day 13–14 — Optional Personal Service

Choose **ONE**:

### Option A

Immich

### Option B

Vaultwarden

---

# Week 3: Cloud & Automation

## Day 15 — Deploy LocalStack

### Tasks

Deploy LocalStack container.

### Validation

* Services start successfully

---

## Day 16 — Install Terraform

### Structure

```text
terraform/
└── localstack/
```

---

## Day 17 — Provision S3 Bucket

### Objective

Create first Terraform-managed resource.

### Validation

* S3 bucket visible in LocalStack

---

## Day 18 — Provision DynamoDB Table

### Objective

Create Terraform-managed DynamoDB table.

### Validation

* Table successfully created

---

## Day 19 — Integrate Monitoring

### Optional

* Connect LocalStack metrics to Grafana

If difficult, continue without blocking progress.

---

## Day 20 — Push Everything to Git

### Tasks

* Commit infrastructure files
* Push repository

### Tag Release

```bash
git tag v0.1
```

---

## Day 21 — Create Architecture Diagram

### Include

```text
Laptop
    │
Tailscale
    │
Ubuntu VM
    │
Docker Services
```

Save diagram inside:

```text
docs/
```

---

# Week 4: Reliability & Validation

## Day 22 — Deploy Loki

### Objective

Collect Docker container logs.

### Validation

* Logs visible in Grafana

---

## Day 23 — Configure Alerts

### Example Alerts

* CPU > 90%
* Disk > 85%
* Service unavailable

### Delivery Method

* Telegram notifications

---

## Day 24 — Headless Operation Test

### Tasks

Disconnect:

* Monitor
* Keyboard
* Mouse

Operate exclusively through remote access.

---

## Day 25 — Recovery Drill #1

### Simulate Reboot

Verify:

* Proxmox starts
* Ubuntu VM starts
* Docker starts
* Tailscale reconnects

---

## Day 26 — Recovery Drill #2

### Simulate Container Failure

Kill Homepage container.

### Objective

Restore service using documented procedures.

---

## Day 27 — Recovery Drill #3

### Simulate Network Failure

* Power off router
* Wait 30 seconds
* Restore power

### Validation

* Automatic reconnection
* Services reachable

---

## Day 28 — Recovery Drill #4

### Backup Restoration

Restore from backup.

### Validation

* Recovery successful
* Data intact

---

## Day 29 — Documentation Review

Verify:

* Setup guide complete
* Troubleshooting guide complete
* Architecture diagram complete

---

## Day 30 — Final Validation

Run the complete readiness checklist.

---

# ✅ College Departure Checklist

## Infrastructure

* [ ] Proxmox reachable
* [ ] Ubuntu VM autostarts
* [ ] Docker autostarts

## Connectivity

* [ ] Tailscale reconnects automatically
* [ ] Remote access verified

## Operations

* [ ] Homepage dashboard operational
* [ ] Grafana dashboard operational
* [ ] Prometheus collecting metrics
* [ ] Loki collecting logs

## Cloud & Automation

* [ ] LocalStack operational
* [ ] Terraform deployments successful

## Reliability

* [ ] Backup verified
* [ ] Recovery procedures tested

## Documentation

* [ ] Git repository up to date
* [ ] Architecture documentation complete
* [ ] Network documentation complete
* [ ] Troubleshooting documentation complete

---

# 🎓 Expected Skills Gained

By completing this roadmap, I will gain hands-on experience with:

* Linux Administration
* Virtualization (Proxmox)
* Networking
* VPN & Remote Access
* Docker & Containers
* Infrastructure as Code (Terraform)
* Monitoring (Prometheus & Grafana)
* Logging (Loki)
* Backup & Recovery
* Incident Response
* Documentation Practices
* Basic Cloud Architecture
* Local AWS Emulation (LocalStack)
* Remote System Operations



Here is a comprehensive, production-grade engineering debrief of exactly what we achieved tonight, structured perfectly so you can paste it directly into your project docs or a post-mortem file.
Engineering Log: Infrastructure Consolidation & IaC Validation

Date: June 3, 2026

Host: ubuntu@athena (Server) | Client: Artemis (Laptop)

Status: Completed (Zero Technical Debt)
🛠️ Summary of What We Did

We successfully closed out the core infrastructure and automation phases of the homelab roadmap. The entire project repository was refactored away from isolated, messy application directories into a clean, unified, and enterprise-grade multi-stack layout. Additionally, we verified the Infrastructure-as-Code (IaC) pipeline, consolidated the telemetry suite, and secured the version control boundary.
🏗️ Technical Execution: How We Did It
1. IaC Verification & LocalStack Validation

    Action: Executed local Terraform configuration blocks from Artemis targeting the remote LocalStack container running over the Tailscale network fabric.

    Verification: Interrogated the local cloud sandbox using the AWS CLI inside a Fish shell to confirm stateful resource creation.

    Confirmed Assets:

        S3 Bucket: tf-homelab-storage-bucket

        DynamoDB Table: tf-homelab-metadata

2. File System Restructuring & Telemetry Fusion

    Action: Dismantled fragmented legacy directories (~/homelab/core-services/ and ~/homelab/monitoring/) on Athena.

    Consolidation: Merged Prometheus, Node-Exporter, Proxmox-Exporter, Loki, and Promtail into a single, unified Docker Compose workspace under ~/homelab/docker-compose/telemetry/.

    Artemis Realignment: Renamed local directory structures to mirror Athena exactly, aligning the Git remote with actual server state.

3. Repository Sanitation & Commit

    Action: Hardened the root .gitignore to mask high-volume persistent storage volumes and state engines.

    Commit: Staged all tracking updates, reconciled deletions, and pushed a clean tracking snapshot to origin main.

⚡ Challenges Faced & Engineering Solutions
Challenge 1: Permission Barrier During Directory Migration

    Symptom: When running mkdir -p ~/homelab/docker-compose/telemetry, the system threw an explicit mkdir: cannot create directory ... Permission denied block.

    Root Cause: Certain subdirectories inside the homelab tree had inherited root:root user ownership from prior decoupled sudo docker executions, blocking the standard ubuntu system user from modifying the tree.

    Solution: Reclaimed absolute recursive user and group ownership of the workspace directory utilizing the change ownership binary:
    Bash

    sudo chown -R $USER:$USER ~/homelab

Challenge 2: Docker Daemon Container Name Conflicts

    Symptom: Initializing the new unified telemetry stack threw a fatal daemon error: Conflict. The container name "/proxmox-exporter" is already in use by... followed immediately by a similar block for /promtail.

    Root Cause: Stale container footprints created by previous docker-compose files were still actively mapped inside the Docker engine daemon's memory namespace.

    Solution: Forcefully purged the legacy runtime allocations by their explicit container identifiers before bringing up the new network bridge:
    Bash

    docker rm -f proxmox-exporter prometheus node-exporter grafana promtail loki
    docker compose up -d

📊 Current Container Architecture Status (docker ps)

The unified telemetry workspace is fully initialized and isolated within a custom bridge network (telemetry_telemetry-net). All 6 microservices are healthy and operating concurrently:

    ✅ loki (Port 3100) — Log aggregation engine

    ✅ prometheus (Port 9090) — Time-series metric database

    ✅ grafana (Port 3001 -> 3000) — Visual analytics dashboard

    ✅ promtail (Host Log Agent) — Shipping container and system logs

    ✅ node-exporter (Port 9100) — Host hardware metrics harvester

    ✅ proxmox-exporter (Port 9221) — Virtualization layer hypervisor telemetry

🎯 Next Objective: Priority 4 (Architecture Diagram)

When you return to the lab, your workspace is perfectly clean and clear to start building out your Mermaid.js network and application architecture diagram inside your initialized docs/architecture-diagram.mmd file.