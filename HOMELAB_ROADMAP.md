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
